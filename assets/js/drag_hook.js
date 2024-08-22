import Sortable from "../vendor/sortable";

export default {
  mounted() {
    const hook = this;

    document.querySelectorAll(".dropzone").forEach((dropzone) => {
      new Sortable(dropzone, {
        animation: 0,
        delay: 50,
        delayOnTouchOnly: true,
        draggable: ".draggable",
        ghostClass: "sortable-ghost",
        group: "shared",
        onStart: function (evt) {
          console.log("dragstart");
        },
        onEnd: function (evt) {
          const payload = {
            id: evt.item.dataset.id,
            from: {
              area: evt.from.id,
              x: parseInt(evt.from.dataset.xCoord),
              y: parseInt(evt.from.dataset.yCoord),
            },
            to: {
              area: evt.to.id,
              x: parseInt(evt.to.dataset.xCoord),
              y: parseInt(evt.to.dataset.yCoord),
            },
          };

          hook.pushEventTo("game_board", "drop_tile", payload);
        },
        onMove: function (evt) {
          if (
            evt.to.classList.contains("slot") &&
            evt.to.childElementCount > 0
          ) {
            return false;
          }
        },
      });
    });
  },
};
