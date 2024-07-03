# Ongoing work on the STM32F401RE

Welcome to my portfolio of embedded systems projects! This repository showcases a series of projects developed using full ARM assembly for the STM32F401RE microcontroller. Each project includes custom system initialization, linker scripts, and follows a structured directory format, drivers, clock configs, timers, and soon a full RTOS task scheduler in the system directory for the kernel. Below is an overview of the projects included:

## Projects Overview

- **System**
    Contains system configurations and other kernel details
- **Sensors**
    Contains sensor projects
- **Drivers**
    Contains drivers for various peripherals that we can make interface with the stm32

## Usage

Each project directory (`LED_Blinking_Project`, `Analog_Sensor_Interface`, etc.) contains its own docs directory with detailed instructions, circuit diagrams, and additional resources. Follow the dev-manual.md in each project folder to set up the environment, compile the code, and run the project on your development platform.

## Getting Started

To get started with any project, clone this repository to your local machine:
git clone [text](https://github.com/anomaly1095/stm32F401RE.git)

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
