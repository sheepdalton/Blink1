
# Urban Analysis Software for Computing Overlapping Isovists

Welcome to the Blink Urban Analysis Software! This tool is designed to compute overlapping isovists for urban environments, aiding in the analysis of spatial visibility and urban design. Built using the Processing programming language, this software offers an intuitive and visual approach to urban analysis.

## Table of Contents
- [Introduction](#introduction)
- [Features](#features)
- [Binaries ](#Binaries )
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Introduction

Isovists are areas visible from a specific point in space, and overlapping isovists provide valuable insights into how different points in an urban environment relate to one another. This software enables users to compute and analyze overlapping isovists, supporting urban planners and researchers in making informed decisions about urban design and development.

## Features

- Compute isovists from multiple points in an urban environment
- Analyze overlapping isovists to understand spatial relationships
- Visualize isovist overlaps using various graphical representations
- Export analysis results for further use and study

## Binaries

Experimentally I have installed 2 Binaries - one for Mac ( AppleSilcon) and another for Windows. These have not been tested and it is uncertain if they will work for GitHub but this attempt might be worth trying. 


## Installation

To install the Urban Analysis Software, follow these steps:

1. Clone the repository:
    ```sh
    git clone https://github.com/sheepdalton/Blink1.git
    ```

2. Open the project in the Processing IDE:
    - Launch the Processing IDE.
    - Open the `Blink1` folder.

3. Ensure you have the required libraries installed:
    - If the project uses any external libraries, download and add them through the Processing IDE.

## Usage

# Operation Instructions
Once the blank window is open you just press single letters on the keyboard to do it ( sorry, will add menu) . Some options are experimental and not listed the main ones are. 

- **`o`**: Open an SVG file ( see example) The file should have a surrouding boundary
- **`n`**: Set the number of isovists
  ## Use either 'g' or 'r' BUT NOT BOTH  
- **`g`**: Generate a grid of isovists
- **`r`**: Generate random isovists (better for fewer isovists can be slow)
  ## To Process all measures 
- **`a`**: Process isovists to compute integration and fractional integration (can take time)

- **`1`** .... **`0`**: Switch between values
- **`1`**: ePureConnectivity
- **`2`**: kFRACTIONAL_CONNECTIVITY ( asymetrical ) 
- **`3`**: kSYMETRIC_CONNETIVITY

- **`4`**: eTOTAL_DEPTH_MEASURE (traditional VGA) 
- **`5`**: kTOTAL_FRACITON_INTEGRATION asymetrical 
- **`6`**: kSYMETRIC_TOTAL_DEPTH  symetrical

- **`7`**: kLog_eTOTAL_DEPTH_MEASURE (traditional VGA) 
- **`8`**: kLog_eTOTAL_DEPTH_MEASURE asymetrical 
- **`6`**: kLog_SYMETRIC_TOTAL_DEPT  symetrical

## Exporting 
- **`t`**: Save table of isovists and data saved in data/comparison.csv 
- **`s`**: Exports current image as PDF file guesses the name. 

- **Click and drag**: Move
- **Scroll wheel**: Zoom
- **Control key + Click**: Add an isovist at the selected point

- **`z`**: Hide down isovists

- **Click on isovist **
  - **`d`**: Fractional depth from nearest isovist
  - **`D`**: Step depth from nearest selected isovist


## Contributing

We welcome contributions from the community! If you would like to contribute to the Urban Analysis Software, please follow these steps:

1. Fork the repository.
2. Create a new branch:
    ```sh
    git checkout -b feature/your-feature-name
    ```
3. Make your changes and commit them:
    ```sh
    git commit -m "Add your commit message here"
    ```
4. Push to the branch:
    ```sh
    git push origin feature/your-feature-name
    ```
5. Open a pull request detailing your changes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.

