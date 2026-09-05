import { Controller } from "@hotwired/stimulus"

// Auto-dismiss toasts
export default class extends Controller {
  connect() {
    setTimeout(() => {
      this.element.classList.add("opacity-0", "translate-y-2")
      setTimeout(() => this.element.remove(), 300)
    }, 3500)
  }

  dismiss() {
    this.element.remove()
  }
}
