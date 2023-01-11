FROM archlinux:base-devel

RUN pacman --noconfirm -Syu git openssl-1.1

RUN groupadd -g 1001 user && useradd -u 1001 -g 1001 -m user

RUN echo "user ALL=(ALL:ALL) NOPASSWD: ALL" >>/etc/sudoers

RUN git clone https://aur.archlinux.org/paru-bin.git && chown user:user paru-bin -R && cd paru-bin && sudo -u user makepkg --noconfirm -si && cd .. && rm -rf paru-bin

WORKDIR /home/user
USER user
