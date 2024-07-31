document.addEventListener("DOMContentLoaded", function () {
    const selectAllCheckbox = document.querySelector('.checkboxAll');
    const productCheckboxes = document.querySelectorAll('.checkbox');

    selectAllCheckbox.addEventListener('change', function () {
        const isChecked = this.checked;
        
        // Update the state of all product checkboxes
        productCheckboxes.forEach(function (checkbox) {
            checkbox.checked = isChecked;
        });
    });
});
