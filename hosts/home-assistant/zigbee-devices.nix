# Zigbee2MQTT per-device settings, keyed by IEEE address. Copied from the HAOS
# add-on. friendly_name is the MQTT topic, so renaming one changes its topic.
{
  "0x00124b0029278716".friendly_name = "Room Door Sensor";
  "0xa4c138f81b40f98d".friendly_name = "Desk Light";
  "0xe0798dfffecf8485".friendly_name = "Presence Sensor";
  "0x70b3d52b600492d6" = {
    friendly_name = "Extenstion Socket";
    homeassistant.name = "Extension Socket";
    legacy = false;
    optimistic = true;
    current_precision = 2;
    measurement_poll_interval = 60;
    description = "For 3D printer, etc";
  };
  "0xa4c138c8a6d3087d" = {
    friendly_name = "Desk Strip";
    homeassistant.name = "Corner light";
    legacy = false;
    optimistic = true;
    transition = 1;
  };
  "0x8c65a3fffeba3e2b" = {
    friendly_name = "Scene Switch";
    homeassistant.name = "Scene switch";
    legacy = false;
    optimistic = true;
  };
  "0x54ef441000b29464" = {
    friendly_name = "CubeControl";
    homeassistant.name = "Cube Control";
    optimistic = true;
  };
  "0xa4c138973a88bff2".friendly_name = "Bedroom Light";
  "0x20a716fffed14002".friendly_name = "Server Rack Socket";
  "0x20a716fffed189b7".friendly_name = "Server Socket";
}
