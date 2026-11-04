"use client";

import React from "react";

export default function OneClickSection() {
  return (
    <div className="c-click" data-click="">
      <div className="c-click__before"></div>
      <div className="c-click__inner" data-click-inner="">
        <canvas
          data-click-canvas=""
          data-artboard="Main - Desktop"
          data-state-machines="SM - All motion desktop"
          className="show-desktop"
          width="1905"
          height="917"
        ></canvas>
        <canvas
          data-click-canvas=""
          data-artboard="Main - Mobile"
          data-state-machines="SM - All motion mobile"
          className="show-mobile"
          width="0"
          height="0"
        ></canvas>
      </div>
    </div>
  );
}
