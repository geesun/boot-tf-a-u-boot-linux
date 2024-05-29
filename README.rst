=======================================================================================
Build and boot Arm64 Linux Kernel on Arm Fixed Virtual Platforms(FVP) Base_RevC_AEMvA
=======================================================================================

This Makefile mainly demonstrates how to achieve booting the latest Linux kernel on Arm's Base FVP using `Arm Trusted Firmware-A <https://www.trustedfirmware.org/projects/tf-a>`_ and `u-boot <https://source.denx.de/u-boot/u-boot>`_ through simple steps.
It also shows how to quickly debug the Linux Kernel using armdbg in Arm DS with simple configurations.

Setup up environment 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Download toolchain and Base RevC FVP 

.. code-block:: sh 

    make download

The latest toolchain and FVP can be found at the links below. 

- `AArch64 GNU/Linux target <https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads>`_
- `Armv-A Base RevC AEM FVP (x86 Linux) <https://developer.arm.com/Tools%20and%20Software/Fixed%20Virtual%20Platforms>`_

2. Clone all source

.. code-block:: sh 

    make clone

Build all images 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Build u-boot tf-a linux and rootfs in one step

.. code-block:: sh 

    make  build

2. Build u-boot tf-a linux and rootfs seperate step 

.. code-block:: sh 

    make  u-boot.build 
    make  tf-a.build 
    make  linux.build 
    make  fs.build 

3. Clean u-boot tf-a linux and rootfs in one step or seperate step 

.. code-block:: sh 

    make  clean  

.. code-block:: sh 

    make  u-boot.clean  
    make  tf-a.clean 
    make  linux.clean 
    make  fs.clean 


Run and debug with Arm DS 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Run the images on  FVP 

By default, the FVP uses xterm for serial port output. In this Makefile, tmux is used instead of xterm. Therefore, please ensure you execute the following command within tmux:

.. code-block:: sh 

    make  run 

2. Debug FVP with Arm DS  

Before debugging, you need to import the Base RevC FVP into Arm DS. Follow similar steps to `import the RevC FVP into Arm DS<https://community.arm.com/oss-platforms/w/docs/649/guide-to-set-up-debugging-environment-for-total-compute-software-stack>`_. Ensure your configuration database is located at ~/developmentstudio-workspace/RevC and that the model name is FVP_Base_RevC_2xAEMvA to match the debug target in the Makefile.
And then type: 

.. code-block:: sh 

    make  debug 

