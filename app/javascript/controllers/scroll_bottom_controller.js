import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.scroll()
    this.observer = new MutationObserver(() => this.scroll())
    this.observer.observe(this.element, {
      childList: true,   // new messages appended
      subtree: true,     // bubbles replaced / updated inside
      characterData: true
    })
  }

  disconnect() {
    this.observer.disconnect()
  }

  scroll() {
    this.element.scrollTop = this.element.scrollHeight
  }
}
