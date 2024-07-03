# 

Welcome to my portfolio of embedded systems projects! This repository showcases a series of projects developed using full ARM assembly for the STM32F401RE microcontroller. Each project includes custom system initialization, linker scripts, and follows a structured directory format, drivers, clock configs, timers, and soon a full RTOS task scheduler in the system directory for the kernel. Below is an overview of the projects included:

## Projects Overview

### LED Blinking Project

- **Description**: Basic project to blink an LED using ARM assembly.
- **Skills Demonstrated**: GPIO configuration, ARM assembly language programming.

### Analog Sensor Interface

- **Description**: Interface with an analog sensor (e.g., temperature sensor) using ARM assembly.
- **Skills Demonstrated**: ADC configuration, analog signal processing, ARM assembly language programming.

### Motor Control Project

- **Description**: Control a DC motor using PWM (Pulse Width Modulation) in ARM assembly.
- **Skills Demonstrated**: Motor driver interfacing, PWM generation, ARM assembly language programming.

### I2C LCD Display Integration

- **Description**: Interface with an I2C LCD display to show text or graphics using ARM assembly.
- **Skills Demonstrated**: I2C protocol basics, LCD initialization over I2C, ARM assembly language programming.

### Advanced Project

- **Description**: Choose an advanced project based on your interest (e.g., wireless communication, sensor fusion, cloud integration) using ARM assembly.
- **Skills Demonstrated**: Advanced hardware interfacing, communication protocols, ARM assembly language programming.

## Repository Structure

├── LED_Blinking_Project/
│ ├── src/
│ ├── bin/
│ ├── docs/
│ ├── linker-script.ld
│ ├── Makefile
│ └── README.md
├── Analog_Sensor_Interface/
│ ├── src/
│ ├── bin/
│ ├── docs/
│ ├── linker-script.ld
│ ├── Makefile
│ └── README.md
├── Motor_Control_Project/
│ ├── src/
│ ├── bin/
│ ├── docs/
│ ├── linker-script.ld
│ ├── Makefile
│ └── README.md
├── I2C_LCD_Display_Integration/
│ ├── src/
│ ├── bin/
│ ├── docs/
│ ├── linker-script.ld
│ ├── Makefile
│ └── README.md
├── Advanced_Project/
│ ├── src/
│ ├── bin/
│ ├── docs/
│ ├── linker-script.ld
│ ├── Makefile
│ └── README.md
├── docs/
│ ├── nucleo-64.pdf
│ ├── STM32F401RE.pdf
│ ├── cortex-m4.pdf
└── README.md

## Usage

Each project directory (`LED_Blinking_Project`, `Analog_Sensor_Interface`, etc.) contains its own docs directory with detailed instructions, circuit diagrams, and additional resources. Follow the dev-manual.md in each project folder to set up the environment, compile the code, and run the project on your development platform.

## Getting Started

To get started with any project, clone this repository to your local machine:

### prerequisits

1. Install arm-none-eabi toolchain for ARM aarch32
2. Install gdb-multiarch (optional)

### bash

git clone <https://github.com/anomaly1095/stm32F401RE.git>
cd stm32F401RE/<project_folder>

Refer to the specific project's dev-manual.md file for further instructions.

## Contributing

If you have suggestions or improvements, feel free to open an issue or a pull request. Contributions and any help are always welcome!
License

This repository is licensed under the MIT License. See the LICENSE file for more details.
Contact

    Email: syoyo1095@gmail.com
    LinkedIn: <https://www.linkedin.com/in/youssef-azaiez-0aa02b2b6>
