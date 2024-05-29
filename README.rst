===================================================================================
Boot Linux Kernel with tf-a and u-boot on Arm FVP Base_RevC_AEMvA
===================================================================================

Download toolchain and Base RevC FVP 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: sh 

    make download

Clone all source
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: sh 

    make clone 

Build all binarys from source 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: sh 

    make  build

Build the rootfs 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: sh 

    make  fs.build


Run FVP 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: sh 

    make  run 

Debug FVP with Arm DS  
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You need import the Base RevC FVP to the Arm DS before debug. And then type: 

.. code-block:: sh 

    make  debug 

