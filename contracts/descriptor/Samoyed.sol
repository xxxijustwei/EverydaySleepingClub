//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/utils/Base64.sol";

import "../libraries/SVG.sol";
import "../libraries/Utils.sol";

library Samoyed {
    function render(uint256 _tokenId) public pure returns (bytes memory) {
        bytes memory hash = abi.encodePacked(
            keccak256(abi.encode("samoyed", _tokenId))
        );
        return
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '<svg xmlns="http://www.w3.org/2000/svg" width="640" height="640" style="background:#fff">',
                            dogeFilter(hash),
                            _skin(),
                            _detail(),
                            _body(),
                            _ear(),
                            _face(),
                            "</svg>"
                        )
                    )
                )
            );
    }

    function dogeFilter(bytes memory hash)
        internal
        pure
        returns (string memory)
    {
        string memory redOffset;
        string memory greenOffset;
        string memory blueOffset;
        {
            redOffset = getColourOffset(hash, 0);
            greenOffset = getColourOffset(hash, 1);
            blueOffset = getColourOffset(hash, 2);
        }

        uint256 seed = utils.getFineSandSeed(hash);
        uint256 octaves = utils.getFineSandOctaves(hash);

        return
            svg.filter(
                string.concat(
                    svg.prop("id", "dogeFilter"),
                    svg.prop("x", "0"),
                    svg.prop("y", "0"),
                    svg.prop("width", "100%"),
                    svg.prop("height", "100%")
                ),
                string.concat(
                    fineSandfeTurbulence(seed, octaves),
                    svg.el(
                        "feComponentTransfer",
                        "",
                        string.concat(
                            svg.el(
                                "feFuncR",
                                string.concat(
                                    svg.prop("type", "gamma"),
                                    svg.prop("offset", redOffset)
                                )
                            ),
                            svg.el(
                                "feFuncG",
                                string.concat(
                                    svg.prop("type", "gamma"),
                                    svg.prop("offset", greenOffset)
                                )
                            ),
                            svg.el(
                                "feFuncB",
                                string.concat(
                                    svg.prop("type", "gamma"),
                                    svg.prop("offset", blueOffset)
                                )
                            ),
                            svg.el(
                                "feFuncA",
                                string.concat(
                                    svg.prop("type", "linear"),
                                    svg.prop("intercept", "1")
                                )
                            )
                        )
                    )
                )
            );
    }

    function fineSandfeTurbulence(uint256 seed, uint256 octaves)
        internal
        pure
        returns (string memory)
    {
        return
            svg.el(
                "feTurbulence",
                string.concat(
                    svg.prop("baseFrequency", "0.01"),
                    svg.prop("numOctaves", utils.uint2str(octaves)),
                    svg.prop("seed", utils.uint2str(seed)),
                    svg.prop("result", "turbs")
                )
            );
    }

    function getColourOffset(bytes memory hash, uint256 offsetIndex)
        internal
        pure
        returns (string memory)
    {
        uint256 shift = utils.getColourOffsetShift(hash, offsetIndex);
        uint256 change = utils.getColourOffsetChange(hash, offsetIndex);
        string memory sign = "";
        if (shift == 1) {
            sign = "-";
        }
        return
            string(
                abi.encodePacked(sign, utils.generateDecimalString(change, 1))
            );
    }

    function _detail() internal pure returns (string memory) {
        return
            string.concat(
                string.concat(
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 140; y: 300; width: 20; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 100; y: 320; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 80; y: 360; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 100; y: 380; width: 80; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 180; y: 360; width: 20; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 200; y: 340; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 220; y: 360; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 540; y: 180; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 560; y: 220; width: 20; height: 20"
                        )
                    )
                ),
                string.concat(
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 100; y: 460; width: 20; height: 100"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 120; y: 540; width: 20; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 140; y: 560; width: 20; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 160; y: 580; width: 40; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 140; y: 460; width: 20; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 160; y: 480; width: 20; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 180; y: 500; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 200; y: 520; width: 40; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 240; y: 480; width: 20; height: 20"
                        )
                    )
                ),
                string.concat(
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 240; y: 500; width: 40; height: 100"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 280; y: 560; width: 20; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 300; y: 580; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 320; y: 480; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 340; y: 500; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 360; y: 520; width: 20; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 380; y: 540; width: 80; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 460; y: 520; width: 40; height: 80"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 480; y: 500; width: 40; height: 60"
                        )
                    )
                ),
                svg.rect(
                    svg.prop(
                        "style",
                        "opacity: 0.4; fill: #000; x: 520; y: 480; width: 20; height: 20"
                    )
                )
            );
    }

    function _body() internal pure returns (string memory) {
        return
            string.concat(
                string.concat(
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 380; y: 120; width: 80; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 360; y: 80; width: 20; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 460; y: 80; width: 20; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 340; y: 60; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 480; y: 60; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 300; y: 40; width: 40; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 500; y: 40; width: 40; height: 20"
                        )
                    )
                ),
                string.concat(
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 280; y: 60; width: 20; height: 120"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 540; y: 60; width: 20; height: 120"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 260; y: 180; width: 20; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 240; y: 220; width: 20; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 220; y: 260; width: 20; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 200; y: 280; width: 20; height: 60"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 180; y: 320; width: 20; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 160; y: 360; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 120; y: 380; width: 40; height: 20"
                        )
                    )
                ),
                string.concat(
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 100; y: 360; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 80; y: 320; width: 20; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 100; y: 300; width: 40; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 180; y: 240; width: 20; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 160; y: 220; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 140; y: 240; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 100; y: 220; width: 40; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 80; y: 240; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 60; y: 260; width: 20; height: 20"
                        )
                    )
                ),
                string.concat(
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 40; y: 280; width: 20; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 20; y: 320; width: 20; height: 60"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 40; y: 380; width: 20; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 60; y: 400; width: 20; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 80; y: 420; width: 20; height: 140"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 100; y: 560; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 120; y: 580; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 140; y: 600; width: 200; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 200; y: 560; width: 40; height: 40"
                        )
                    )
                ),
                string.concat(
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 180; y: 540; width: 40; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 160; y: 520; width: 40; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 140; y: 500; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 240; y: 500; width: 20; height: 80"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 260; y: 580; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 340; y: 520; width: 20; height: 80"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 320; y: 500; width: 20; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 360; y: 560; width: 120; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 480; y: 520; width: 20; height: 40"
                        )
                    )
                ),
                string.concat(
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 500; y: 500; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 460; y: 580; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 480; y: 600; width: 60; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 540; y: 580; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 560; y: 540; width: 20; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 580; y: 220; width: 20; height: 320"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 560; y: 180; width: 20; height: 40"
                        )
                    )
                )
            );
    }

    function _skin() internal pure returns (string memory) {
        return
            string.concat(
                string.concat(
                    svg.rect(
                        svg.prop(
                            "style",
                            "filter: url(#dogeFilter); x: 40; y: 320; width: 20; height: 60"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "filter: url(#dogeFilter); x: 60; y: 280; width: 20; height: 120"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "filter: url(#dogeFilter); x: 80; y: 260; width: 20; height: 160"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "filter: url(#dogeFilter); x: 100; y: 240; width: 20; height: 320"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "filter: url(#dogeFilter); x: 120; y: 240; width: 20; height: 340"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "filter: url(#dogeFilter); x: 140; y: 240; width: 60; height: 360"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "filter: url(#dogeFilter); x: 200; y: 340; width: 20; height: 200"
                        )
                    )
                ),
                string.concat(
                    svg.rect(
                        svg.prop(
                            "style",
                            "filter: url(#dogeFilter); x: 220; y: 300; width: 20; height: 260"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "filter: url(#dogeFilter); x: 240; y: 260; width: 20; height: 360"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "filter: url(#dogeFilter); x: 260; y: 220; width: 20; height: 400"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "filter: url(#dogeFilter); x: 280; y: 60; width: 80; height: 540"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "filter: url(#dogeFilter); x: 360; y: 120; width: 120; height: 440"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "filter: url(#dogeFilter); x: 480; y: 60; width: 80; height: 540"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "filter: url(#dogeFilter); x: 560; y: 220; width: 20; height: 320"
                        )
                    )
                )
            );
    }

    function _ear() internal pure returns (string memory) {
        return
            string.concat(
                string.concat(
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 320; y: 100; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 340; y: 120; width: 20; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #ff6464; x: 320; y: 120; width: 20; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 500; y: 100; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 480; y: 120; width: 20; height: 40"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #ff6464; x: 500; y: 120; width: 20; height: 40"
                        )
                    )
                )
            );
    }

    function _face() internal pure returns (string memory) {
        return
            string.concat(
                string.concat(
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 360; y: 220; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 340; y: 220; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 360; y: 200; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 460; y: 220; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 480; y: 220; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 460; y: 200; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 400; y: 260; width: 80; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 420; y: 280; width: 40; height: 20"
                        )
                    )
                ),
                string.concat(
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 320; y: 340; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 520; y: 340; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 340; y: 360; width: 180; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "opacity: 0.4; fill: #000; x: 400; y: 380; width: 80; height: 20"
                        )
                    )
                ),
                string.concat(
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 340; y: 300; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 500; y: 300; width: 20; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 360; y: 320; width: 140; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 380; y: 340; width: 100; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 400; y: 360; width: 80; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #000; x: 420; y: 380; width: 40; height: 20"
                        )
                    ),
                    svg.rect(
                        svg.prop(
                            "style",
                            "fill: #ff6464; x: 420; y: 340; width: 40; height: 40"
                        )
                    )
                )
            );
    }
}
