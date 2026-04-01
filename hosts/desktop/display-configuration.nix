{ ... }:
{
  home.file.".config/kwinoutputconfig.json".text = ''
    [
        {
            "data": [
                {
                    "allowDdcCi": true,
                    "allowSdrSoftwareBrightness": true,
                    "autoRotation": "InTabletMode",
                    "brightness": 1,
                    "colorPowerTradeoff": "PreferAccuracy",
                    "colorProfileSource": "EDID",
                    "connectorName": "HDMI-A-1",
                    "detectedDdcCi": false,
                    "edidHash": "c490d95e4056b2fd9c9eaaa510b84c0a",
                    "edidIdentifier": "PHL 0 16843009 1 2015 0",
                    "edrPolicy": "always",
                    "highDynamicRange": false,
                    "iccProfilePath": "",
                    "maxBitsPerColor": 0,
                    "mode": {
                        "height": 1080,
                        "refreshRate": 60000,
                        "width": 1920
                    },
                    "overscan": 0,
                    "rgbRange": "Automatic",
                    "scale": 1,
                    "sdrBrightness": 200,
                    "sdrGamutWideness": 1,
                    "transform": "Normal",
                    "uuid": "132299ce-789e-46ff-86e5-0d75e11d8148",
                    "vrrPolicy": "Never",
                    "wideColorGamut": false
                },
                {
                    "allowDdcCi": true,
                    "allowSdrSoftwareBrightness": true,
                    "autoRotation": "InTabletMode",
                    "brightness": 1,
                    "colorPowerTradeoff": "PreferAccuracy",
                    "colorProfileSource": "EDID",
                    "connectorName": "DP-1",
                    "detectedDdcCi": false,
                    "edidHash": "f211cb0460a11ad1896f3050a36f2712",
                    "edidIdentifier": "GSM 23349 16843009 11 2016 0",
                    "edrPolicy": "always",
                    "highDynamicRange": false,
                    "iccProfilePath": "",
                    "maxBitsPerColor": 0,
                    "mode": {
                        "height": 1080,
                        "refreshRate": 74973,
                        "width": 1920
                    },
                    "overscan": 0,
                    "rgbRange": "Automatic",
                    "scale": 1,
                    "sdrBrightness": 200,
                    "sdrGamutWideness": 1,
                    "transform": "Normal",
                    "uuid": "6aa5263c-3490-4ea2-8078-e78c21803eb4",
                    "vrrPolicy": "Never",
                    "wideColorGamut": false
                }
            ],
            "name": "outputs"
        },
        {
            "data": [
                {
                    "lidClosed": false,
                    "outputs": [
                        {
                            "enabled": true,
                            "outputIndex": 0,
                            "position": {
                                "x": 1920,
                                "y": 0
                            },
                            "priority": 0,
                            "replicationSource": ""
                        },
                        {
                            "enabled": true,
                            "outputIndex": 1,
                            "position": {
                                "x": 0,
                                "y": 0
                            },
                            "priority": 1,
                            "replicationSource": ""
                        }
                    ]
                }
            ],
            "name": "setups"
        }
    ]
  '';
}