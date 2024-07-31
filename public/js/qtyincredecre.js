document.addEventListener("DOMContentLoaded", function () {

    const plus = document.querySelector(".fa-plus-circle"),
        minus = document.querySelector(".fa-minus-circle"),
        num = document.querySelector(".num"),
        quantityInput = document.querySelector(".quantity-input");

    let a = 1;

    plus.addEventListener("click", () => {
        a++;
        num.innerText = a;
        quantityInput.value = a; // Update the input value
        console.log(a);
    }); 

    minus.addEventListener("click", () => {
        if (a > 1) {
            a--;
            num.innerText = a;
            quantityInput.value = a; // Update the input value
            console.log(a);
        }
    });
});
