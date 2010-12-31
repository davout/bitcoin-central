function wizardNextStep(elt) {
    elt = $(elt);

    step = elt.up("div.transfer-wizard").id;

    switch (step) {
        case "category-step":
            $('category').value = elt.id;
            $('category-step').hide();
            $('currency-step').show();

            break;

        case "currency-step":
            $('currency').value = elt.id;
            $('currency-step').hide();

            $($('category').value + "-" + $('currency').value).show();

            break;
    }
}