#!/bin/bash

setup_nealhost() {
    # install packages
    PACKAGES=(stow)
    paru -Sy --noconfirm $PACKAGES
}

