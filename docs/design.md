Design thoughts
===
## Hardware requirements

* FPGA
* PC
* Router
* UART Camera * 2
* VGA Monitor
* Wire

## Component functions
### UART Camera
Take pictures of the canvas continously. Send the image back to FPGA using UART (DMA is supposed to be used here).

### Router
Connect PC and FPGA using wired/wireless connections

### PC
Control the working mode of the system

Receive key events from FPGA

Extend function: recognize the music using DNN algorithms

Send music scores to the FPGA

### FPGA
Capture the finger knocking action from the visual signal by hardware algorithm

Send key events and receive music scores

Display the key events, the music scores and sound waves on the monitor.

## Workload distribution

* Network connection: bakser
* VGA display: bakser
* PC client with smart recognition: bakser
* Camera DMA: laekov
* Action capture algorithm: laekov

