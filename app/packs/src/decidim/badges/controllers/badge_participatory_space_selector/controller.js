import { Controller } from "@hotwired/stimulus"

class OptgroupManager {
  constructor(selectId) {
    this.select = document.getElementById(selectId);
    this.optgroups = this.select.querySelectorAll("optgroup");
  }

  hideAll() {
    this.optgroups.forEach((optgroup) => {
      optgroup.style.display = "none";
    });
  }

  showSpecific(labels) {
    labels.forEach((label) => {
      const optgroup = this.select.querySelector(`optgroup[label="${label}"]`);
      if (optgroup) {
        optgroup.style.display = "block";
      }
    });
  }

  showOnly(label) {
    this.hideAll();
    this.showSpecific([label]);
  }
}

export default class extends Controller {

  connect() {
    this.componentManager = new OptgroupManager(this.element.dataset.componentManager);

    this.handleSelectChange = this.handleSelectChange.bind(this);

    this.element.addEventListener("change",  this.handleSelectChange);

    this.handleComponentChange();

  }

  disconnect() {
    if (this.handleSelectChange) {
      this.element.removeEventListener("change", this.handleSelectChange)
    }
  }

  handleComponentChange(){
    if (this.element.selectedIndex > 0) {
      const selectedOption = this.element.options[this.element.selectedIndex];
      const textContent = selectedOption.textContent;
      // Hide all optgroups
      this.componentManager.hideAll();
      this.componentManager.showOnly(textContent);
    } else {
      this.componentManager.hideAll();
    }
  }

  handleSelectChange(event) {
    const selectedOption = event.target.options[event.target.selectedIndex];
    const textContent = selectedOption.textContent;
    this.componentManager.select.value = "";
    // Hide all optgroups
    this.componentManager.hideAll();
    this.componentManager.showOnly(textContent);
  }
}
