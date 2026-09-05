import { Controller } from "@hotwired/stimulus"
import confetti from "canvas-confetti"

export default class extends Controller {
  static values = { autofire: { type: Boolean, default: false } }

  connect() {
    if (this.autofireValue || this.element.hasAttribute("data-autofire")) {
      this.fire()
    }
  }

  fire() {
    confetti({
      particleCount: 90,
      spread: 70,
      origin: { y: 0.6 },
      colors: ["#C4712A", "#1B1031", "#A34054", "#5F6C5D", "#E8BCB9"]
    })
  }
}
