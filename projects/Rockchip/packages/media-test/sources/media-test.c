
#include <errno.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/media.h>
#include <linux/videodev2.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include <sys/sysmacros.h>
#include <libudev.h>

#define V4L2_REQUEST_MEDIA_PATH "/dev/media0"

int main(int argc, char *argv[])
{
        struct udev *udev = udev_new();
        struct udev_enumerate* enumerate = udev_enumerate_new(udev);

        udev_enumerate_add_match_subsystem(enumerate, "media");
        udev_enumerate_scan_devices(enumerate);
        
        struct udev_list_entry *devices = udev_enumerate_get_list_entry(enumerate);
        struct udev_list_entry *entry;
        
        udev_list_entry_foreach(entry, devices) {
                const char* path = udev_list_entry_get_name(entry);
                printf("path=%s\n", path);
                struct udev_device* device = udev_device_new_from_syspath(udev, path);
                const char *devnode = udev_device_get_devnode(device);
                printf("devnode=%s\n", devnode);
                udev_device_unref(device);
        }
        printf("\n");

        udev_enumerate_unref(enumerate);
        
        
        int media_fd = open(V4L2_REQUEST_MEDIA_PATH, O_RDWR | O_NONBLOCK, 0);
        if (media_fd < 0) {
                printf("opening %s failed, %s (%d)\n", V4L2_REQUEST_MEDIA_PATH, strerror(errno), errno);
                return 0;
        }

        struct media_device_info device_info = {0};
        struct media_v2_topology topology = {0};
        struct media_v2_entity entities[10] = {0};
        struct media_v2_interface interfaces[10] = {0};
        int ret, i;
        
        ret = ioctl(media_fd, MEDIA_IOC_DEVICE_INFO, &device_info);
        if (ret < 0) {
                printf("get media device info failed, %s (%d)\n", __func__, strerror(errno), errno);
                goto fail;
        }

        printf("driver=%s\n", device_info.driver);
        printf("model=%s\n", device_info.model);
        printf("serial=%s\n", device_info.serial);
        printf("bus_info=%s\n", device_info.bus_info);
        printf("media_version=%u\n", device_info.media_version);
        printf("hw_revision=%u\n", device_info.hw_revision);
        printf("driver_version=%u\n", device_info.driver_version);
        printf("\n");

        ret = ioctl(media_fd, MEDIA_IOC_G_TOPOLOGY, &topology);
        if (ret < 0) {
                printf("get media device info failed, %s (%d)\n", __func__, strerror(errno), errno);
                goto fail;
        }

        printf("num_entities=%u\n", topology.num_entities);
        printf("num_interfaces=%u\n", topology.num_interfaces);
        printf("num_pads=%u\n", topology.num_pads);
        printf("num_links=%u\n", topology.num_links);
        printf("\n");

        topology.ptr_entities = (__u32)entities;
        topology.ptr_interfaces = (__u32)interfaces;

        ret = ioctl(media_fd, MEDIA_IOC_G_TOPOLOGY, &topology);
        if (ret < 0) {
                printf("get media device info failed, %s (%d)\n", __func__, strerror(errno), errno);
                goto fail;
        }

        for (i = 0; i < topology.num_entities; i++) {
                printf("id=%u\n", entities[i].id);
                printf("name=%s\n", entities[i].name);
                printf("function=%u\n", entities[i].function);
                printf("flags=%u\n", entities[i].flags);
                printf("\n");
        }

        for (i = 0; i < topology.num_interfaces; i++) {
                printf("id=%u\n", interfaces[i].id);
                printf("intf_type=%u\n", interfaces[i].intf_type);
                printf("flags=%u\n", interfaces[i].flags);
                printf("major=%u\n", interfaces[i].devnode.major);
                printf("minor=%u\n", interfaces[i].devnode.minor);
                printf("\n");

                char video_path[128] = {0};
                dev_t devnum = makedev(interfaces[i].devnode.major, interfaces[i].devnode.minor);
                struct udev_device *device = udev_device_new_from_devnum(udev, 'c', devnum);
                if (device) {
                        const char *devname = udev_device_get_devnode(device);
                        if (devname) {
                                strncpy(video_path, devname, sizeof(video_path));
                                video_path[sizeof(video_path) - 1] = '\0';
                        }
                        udev_device_unref(device);
                }
                
                printf("video_path=%s\n", video_path);
                
                int video_fd = open(video_path, O_RDWR | O_NONBLOCK, 0);
                if (video_fd < 0) {
                        printf("opening %s failed, %s (%d)\n", video_path, strerror(errno), errno);
                        continue;
                }
                
                struct v4l2_capability capability = {0};
                unsigned int capabilities = 0;

                ret = ioctl(video_fd, VIDIOC_QUERYCAP, &capability);
                if (ret < 0) {
                        printf("get video capability failed, %s (%d)\n", strerror(errno), errno);
                }
                
                if (capability.capabilities & V4L2_CAP_DEVICE_CAPS)
                        capabilities = capability.device_caps;
                else
                        capabilities = capability.capabilities;
                
                printf("capabilities=%u\n", capabilities);
                printf("\n");
                
                close(video_fd);
        }

        udev_unref(udev);

fail:
        close(media_fd);
        return 0;
}
