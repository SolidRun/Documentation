# Fan Control for LX2160A COM Express Module

The COM has an [AMC6821 fan controller](https://www.ti.com/product/AMC6821) assembled. It is directly wired to the thermal diode inside the SoC and can adjust the fan speed autonomously based on temperature and configuration.

## Tuning for quiet operation

### Fan speed

The following strategy can be employed to make the system run quiet:

1. raise what temperature is considered *low* - from the default of 48°C to 64°C.
  The SoC maximum operating temperature is 105°C - therefore this choice is safe.

2. lower the fan speed slope to 1.57% per °C.
  The fan speed will be raised with rising temperature, till eventually reaching full speed at 101°C.

Settings 1 and 2 are made combined, by configuring the fan controller's `Remote TEMP-FAN Control Register 0x25` to `0b10000011` or `0x83`. Bits 7-3 specify the "low" temperature in increments of 4°C; Bits 0-2 specify the slope.

This value can be written directoy to the i2c bus from Linux:

    i2cset -f -y 0 0x18 0x25 0x83

or via the driver in sysfs

    echo 64000 > /sys/devices/platform/soc/2000000.i2c/i2c-0/i2c-4/4-0018/hwmon/hwmon1/temp2_auto_point2_temp
    echo 101000 > /sys/devices/platform/soc/2000000.i2c/i2c-0/i2c-4/4-0018/hwmon/hwmon1/temp2_auto_point3_temp

### Thermal thresholds

LX2160A Cores have 2 configurable thresholds that affect thermals.

1. Throttle - beyond this temperature the cpu will clock down to 1GHz

   For a quiet system, throttling can be enabled early, e.g. at 72°C:

       echo 72000 | tee /sys/class/thermal/thermal_zone{0,1,2,3,4,5,6}/trip_point_0_temp

   For performance however it should enable as late as possible, but ideally before shutdown below:

       echo 100000 | tee /sys/class/thermal/thermal_zone{0,1,2,3,4,5,6}/trip_point_0_temp

2. Shutdown - beyond this temperature the system will trigger shutdown

   By default this threshold is set to 95°C, but as the SoC can sustain 105°C - for sustained loads it may be raised to 105°C:

       echo 105000 | tee /sys/class/thermal/thermal_zone{0,1,2,3,4,5,6}/trip_point_1_temp
