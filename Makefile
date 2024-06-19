SRC_DIR 		:= $(shell pwd)/src
TOOLS_DIR 		:= $(shell pwd)/tools
CROSS_COMPILE 	:= $(TOOLS_DIR)/arm-gnu-toolchain-13.2.Rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-
CC 				:= $(CROSS_COMPILE)gcc
LD 				:= $(CROSS_COMPILE)ld
FVP_BASE 	    := $(TOOLS_DIR)/Base_RevC_AEMvA_pkg/models/Linux64_GCC-9.3/FVP_Base_RevC-2xAEMvA
GRUB_BUSYBOX_IMG := $(shell pwd)/rootfs/grub-busybox.img

UBOOT_CONFIG 	:= vexpress_aemv8a_semi_config 
BOOTARGS		:= "CONFIG_BOOTARGS=\"console=ttyAMA0 earlycon=pl011,0x1c090000 root=/dev/vda1 rw ip=dhcp debug user_debug=31 loglevel=9 \""
BOOTCMD			:= "CONFIG_BOOTCOMMAND=\"booti 0x80080000 - 0x83000000\""
JOBS 			:= $(shell nproc)

FVP_OPTIONS 	:= \
	-C cluster0.NUM_CORES=4 -C cluster1.NUM_CORES=4 \
	-C cluster0.has_arm_v8-3=1 -C cluster1.has_arm_v8-3=1 \
	-C cluster0.has_arm_v8-5=1 -C cluster1.has_arm_v8-5=1 \
	-C cluster0.has_branch_target_exception=1 -C cluster1.has_branch_target_exception=1 \
	-C cluster0.memory_tagging_support_level=4   \
	-C cluster1.memory_tagging_support_level=4   \
	-C cache_state_modelled=0 \
	-C pctl.startup=0.0.0.0 \
	-C bp.secure_memory=1   \
	-C bp.ve_sysregs.exit_on_shutdown=1 \
	-C bp.secureflashloader.fname=$(SRC_DIR)/tf-a/build/fvp/debug/bl1.bin \
	-C bp.flashloader0.fname=$(SRC_DIR)/tf-a/build/fvp/debug/fip.bin \
	--data cluster0.cpu0=$(SRC_DIR)/linux/arch/arm64/boot/Image@0x80080000  \
	--data cluster0.cpu0=$(SRC_DIR)/linux/arch/arm64/boot/dts/arm/fvp-base-revc.dtb@0x83000000  \
	-C bp.ve_sysregs.mmbSiteDefault=0    \
	-C bp.terminal_0.terminal_command="tmux split-window -h telnet localhost %port" \
	-C bp.virtioblockdevice.image_path=$(GRUB_BUSYBOX_IMG) \
	-C pci.pci_smmuv3.mmu.SMMU_AIDR=2   \
	-C pci.pci_smmuv3.mmu.SMMU_IDR0=0x0046123B   \
	-C pci.pci_smmuv3.mmu.SMMU_IDR1=0x00600002   \
	-C pci.pci_smmuv3.mmu.SMMU_IDR3=0x1714   \
	-C pci.pci_smmuv3.mmu.SMMU_IDR5=0xFFFF0475   \
	-C pci.pci_smmuv3.mmu.SMMU_S_IDR1=0xA0000002   \
	-C pci.pci_smmuv3.mmu.SMMU_S_IDR2=0   \
	-C pci.pci_smmuv3.mmu.SMMU_S_IDR3=0   \
	-C pci.pci_smmuv3.mmu.SMMU_ROOT_IDR0=3   \
	-C pci.pci_smmuv3.mmu.SMMU_ROOT_IIDR=0x43B   \
	-C pci.pci_smmuv3.mmu.root_register_page_offset=0x20000   \

DEBUG_OPTIONS 	:= $(subst ",\",$(FVP_OPTIONS)) -I -p

.PHONY: all clone download u-boot.build u-boot.clean tf-a.build tf-a.clean linux.build linux.clean build run debug clean fs.build fs.clean  buildroot.build buildroot.clean

all: clone download build 

clone:
	@ mkdir -p $(SRC_DIR)
	@ [ -d "$(SRC_DIR)/u-boot" ] || git clone https://git.denx.de/u-boot $(SRC_DIR)/u-boot
	@ [ -d "$(SRC_DIR)/tf-a" ] || git clone https://git.trustedfirmware.org/TF-A/trusted-firmware-a  $(SRC_DIR)/tf-a
	@ [ -d "$(SRC_DIR)/linux" ] || git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git $(SRC_DIR)/linux
	@ [ -d "$(SRC_DIR)/buildroot" ] || git clone https://gitlab.com/buildroot.org/buildroot.git $(SRC_DIR)/buildroot

download:
	@ mkdir -p $(TOOLS_DIR)
	@ [ -f "$(TOOLS_DIR)/FVP_Base_RevC-2xAEMvA_11.25_15_Linux64.tgz" ] || wget -P $(TOOLS_DIR) https://armkeil.blob.core.windows.net/developer/Files/downloads/ecosystem-models/FM_11_25/FVP_Base_RevC-2xAEMvA_11.25_15_Linux64.tgz
	@ [ -f "$(TOOLS_DIR)/arm-gnu-toolchain-13.2.rel1-x86_64-aarch64-none-linux-gnu.tar.xz" ] || wget -P $(TOOLS_DIR) https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-x86_64-aarch64-none-linux-gnu.tar.xz
	@ [ -d "$(TOOLS_DIR)/Base_RevC_AEMvA_pkg" ] || tar -C $(TOOLS_DIR) -zxvf $(TOOLS_DIR)/FVP_Base_RevC-2xAEMvA_11.25_15_Linux64.tgz
	@ [ -d "$(TOOLS_DIR)/arm-gnu-toolchain-13.2.Rel1-x86_64-aarch64-none-linux-gnu" ] || tar -C $(TOOLS_DIR) -xvf $(TOOLS_DIR)/arm-gnu-toolchain-13.2.rel1-x86_64-aarch64-none-linux-gnu.tar.xz


u-boot.build:
	export ARCH=aarch64 ; \
	export CROSS_COMPILE=$(CROSS_COMPILE) ; \
	cd $(SRC_DIR)/u-boot ;\
	echo $(BOOTARGS) > fvp.cfg; \
	echo $(BOOTCMD) >> fvp.cfg; \
	make -j $(JOBS)  $(UBOOT_CONFIG);\
	scripts/kconfig/merge_config.sh -m -O ./ .config fvp.cfg; \
	make -j $(JOBS)  ;

u-boot.clean:
	make -C $(SRC_DIR)/u-boot clean 

tf-a.build: u-boot.build
	export CROSS_COMPILE=$(CROSS_COMPILE) ; \
	cd $(SRC_DIR)/tf-a; \
	make PLAT=fvp DEBUG=1 BL33=$(SRC_DIR)/u-boot/u-boot.bin all fip V=1 ENABLE_FEAT_MTE2=1

tf-a.clean: 
	export CROSS_COMPILE=$(CROSS_COMPILE) ; \
	make PLAT=fvp -C $(SRC_DIR)/tf-a  realclean

linux.build: 
	[ -f "$(SRC_DIR)/linux/.config" ] ||  make -C $(SRC_DIR)/linux ARCH=arm64 defconfig CROSS_COMPILE=$(CROSS_COMPILE)
	make -C $(SRC_DIR)/linux ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE) olddefconfig
	make -C $(SRC_DIR)/linux ARCH=arm64 -j $(JOBS) CROSS_COMPILE=$(CROSS_COMPILE) Image dtbs modules

linux.mod:
	make -C $(SRC_DIR)/linux ARCH=arm64 -j $(JOBS) CROSS_COMPILE=$(CROSS_COMPILE) modules
	make -C $(SRC_DIR)/linux ARCH=arm64 -j $(JOBS) CROSS_COMPILE=$(CROSS_COMPILE) INSTALL_MOD_PATH=$(shell pwd)/rootfs/overlay  modules_install

linux.clean:
	make -C $(SRC_DIR)/linux ARCH=arm64 clean 

buildroot.build:
	cp buildroot.cfg $(SRC_DIR)/buildroot/configs/arm_aem_fvp_defconfig
	make -C $(SRC_DIR)/buildroot arm_aem_fvp_defconfig
	make -C $(SRC_DIR)/buildroot  -j $(JOBS)
	mkdir -p rootfs/tmp/rootfs/ -p && cd rootfs/tmp/rootfs && tar -xvf $(SRC_DIR)/buildroot/output/images/rootfs.tar
	[ -z "$(shell ls -A rootfs/overlay)" ] || cp rootfs/overlay/* rootfs/tmp/rootfs/ -a
	cd rootfs/tmp && ../gen-rootfs
	rm -rf rootfs/tmp

buildroot.clean:
	make -C $(SRC_DIR)/buildroot clean

buildroot.savecfg:
	make -C $(SRC_DIR)/buildroot savedefconfig
	cp $(SRC_DIR)/buildroot/configs/arm_aem_fvp_defconfig  buildroot.cfg

fs.build:
	mkdir -p rootfs/tmp -p && cd rootfs/tmp && tar -jxvf ../rootfs.tar.bz2
	[ -z "$(shell ls -A rootfs/overlay)" ] || cp rootfs/overlay/* rootfs/tmp/rootfs/ -a
	cd rootfs/tmp && ../gen-rootfs
	rm -rf rootfs/tmp

fs.clean: 
	rm -rf $(GRUB_BUSYBOX_IMG)
		
build: u-boot.build tf-a.build linux.build buildroot.build

run:
	$(FVP_BASE) $(FVP_OPTIONS)

debug:
	/opt/arm/developmentstudio_platinum-0.a/bin/armdbg \
		--cdb-entry="Imported::FVP_Base_RevC_2xAEMvA::Bare Metal Debug::Bare Metal Debug::ARM_AEM-A_MPx4 SMP Cluster 0" \
		--cdb-root ~/developmentstudio-workspace/RevC \
		-cdb-entry-param model_params="$(DEBUG_OPTIONS)" -s ap.ds --interactive

clean: fs.clean linux.clean tf-a.clean u-boot.clean buildroot.clean

distclean:
	rm -rf $(GRUB_BUSYBOX_IMG)
	rm -rf $(SRC_DIR) $(TOOLS_DIR)


