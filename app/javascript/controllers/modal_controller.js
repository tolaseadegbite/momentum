import { Controller } from "@hotwired/stimulus"

// Handles modal open/close, ESC + backdrop click
export default class extends Controller {
  static targets = ["backdrop", "panel"]

  connect() {
    document.addEventListener("keydown", this.onKey)
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKey)
  }

  onKey = (e) => {
    if (e.key === "Escape") this.close()
  }

  closeOnBackdrop(e) {
    if (e.target === this.backdropTarget) this.close()
  }

  close() {
    const frame = document.getElementById("modal")
    if (frame) frame.innerHTML = ""
    this.element.remove()
  }
}
