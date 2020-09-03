# obj_#3 - Bryan Dunphy

This is an interactive virtual reality sculpture built using the ImmersAV toolkit. It can be built and installed
by following the instructions here:

## Dependencies:
- OpenVR
- Csound6
- OpenGL4
- glm
- glfw3
- Glew
- CMake3
- RapidLib
- libsndfile

## Windows:

### Setup:
1. Download (64 bit):
    - CMake:        https://cmake.org/download/
    - OpenVR:       https://github.com/ValveSoftware/openvr
    - Csound 6:     https://csound.com/download.html
    - glm:          https://github.com/g-truc/glm/tags
    - glfw3:        https://www.glfw.org/download.html
    - glew:         http://glew.sourceforge.net/
    - libsndfile:   http://www.mega-nerd.com/libsndfile/#Download
2. Install CMake and Csound according to their instructions.
3. Create directories:
    - `obj_3/bin/`
    - `obj_3/lib/` 
    - `obj_3/include/` 
4. Move the following files to `bin/`:
    - csound64.dll
    - glew32.dll
    - openvr_api.dll
    - libsndfile-1.dll
5. Move the following files to `lib/`:
    - csound64.lib
    - openvr_api.lib
    - glew32.lib
    - glfw3.lib
    - libsndfile-1.lib
6. Move header files from OpenVR to `include/`.

### Build and run using the Visual Studio command line:

1. Run the newCmakeBuild.bat script.
2. Use the following commands to build the project:
```
    cd build/
    nmake
```
3. Move the following files to `obj_3/build/src/`:
    - From `obj_3/bin/`:
        - csound64.dll
        - openvr_api.dll
        - glew32.dll
        - libsndfile-1.dll
    - From `obj_3/data/`: 
        - hrtf-48000-left.dat
        - hrtf-48000-right.dat
        - avr_iml_actions.json
        - avr_iml_default_bindings.json
        - obj_3.csd
        - obj_3.vert
        - obj_3.frag
4. Navigate (cd) to `obj_3/build/src/`.
5. Type the following command to run the application:
    - With VR rendering:
        `avr`
    - Without VR rendering (for development):
        `avr -dev`

## MacOS:

### Setup:
1. Download (64 bit):
    - CMake         https://cmake.org/download/
    - OpenVR:       https://github.com/ValveSoftware/openvr
    - Csound 6:     https://csound.com/download.html
    - glm:          https://github.com/g-truc/glm/tags
    - glfw3:        https://www.glfw.org/download.html
    - RAPID-MIX:    https://www.doc.gold.ac.uk/eavi/rapidmixapi.com/index.php/getting-started/download-and-setup/
2. Install CMake and Csound according to their instructions.
3. Move the following to `/Library/Frameworks/`:
    - CsoundLib64.framework 
    - OpenVR.framework
4. Move the following to `/usr/local/lib/`:
    - libcsnd.6.0.dylib
    - libcsnd6.6.0.dylib
    - libopenvr_api.dylib
    - libRAPID-MIX_API.dylib
5. Create `obj_3/include/` directory.
6. Move the following to `obj_3/include/`:
    - From `openvr/`:
        - headers/*
    - From `RAPID-MIX_API/src`:
        - rapidmix.h
        - machineLearning/*
        - signalProcessing/*
        
### Build and Run using the terminal:

1. Type the following commands into the terminal:
    ```
    mkdir build/
    cd build
    cmake ..
    ```
2. When CMake has prepared the build files type `make`.
3. Move the following files to `obj_3/build/src/`: 
    - From `obj_3/data/`:
        - hrtf-48000-left.dat
        - hrtf-48000-right.dat
        - avr_iml_actions.json
        - avr_iml_default_bindings.json
        - obj_3.csd
        - obj_3.vert
        - obj_3.frag
4. Navigate (cd) to `obj_3/build/src/`.
5. To run the application type the following into the terminal:
    - With VR rendering (NB. virtual reality rendering has not been tested on macOS and will almost certainly not work at the moment.):
        `./avr`
    - Without VR (for development):
        `./avr -dev`

## Useage

## with VR

### Controller Setup
HTC Vive:
 
Right controller:
 
- Trigger -> random parameters
- Grip -> train model
- Trackpad -> (press) save trained model
 
Left controller:
 
- Trigger -> record training example
- Grip -> run / stop model
- Trackpad -> (press) load trained model

 
### Using the system:
1. Randomise parameters until you find audio and visual parameters that you like.
2. Hold both controllers in a position in space of your choice and press record.
3. Repeat steps 1 and 2 as many times as you like making sure to choose sufficiently different controller positions each time you record.
4. Train the model.
5. Run the model.
6. Explore the audiovisual space by moving and rotating the controllers.
7. Stop the model to freely move around the object without affecting the parameters. This is useful if you find an interesting form and want to investigate.
  
WARNING: If you try to load a model without saving one first the application will crash.

## without VR
- space bar -> randomise parameters
- w -> forward
- s -> back
- a -> left
- d -> right

Interactive machine learning functionality is not available without VR system.
