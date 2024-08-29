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
        onEnd: function (evt) {
          if (evt.to.id == "hand") {
            hook.pushEventTo("#game_board", "drop_tile", {
              id: evt.item.dataset.id,
              handIndex: evt.newIndex,
            });
          } else {
            hook.pushEventTo("#game_board", "drop_tile", {
              id: evt.item.dataset.id,
              boardPosition: {
                row: parseInt(evt.to.dataset.row),
                column: parseInt(evt.to.dataset.column),
              },
            });
          }
        },
        onMove: function (evt) {
          if (
            evt.to.classList.contains("slot") &&
            evt.to.querySelector(".tile")
          ) {
            return false;
          }
        },
      });
    });
  },
};
