$(document).ready(function() {
    $(".trigger-total-update").bind("click keypress keyup blur", updateTotal);

    // Triggered by a currency or category selection on
    // the trade order creation form
    // TODO : DRY this up with body class/id
    $("input.currency-select").click(updateTradeOrderForm);
    $("input.category-select").click(updateTradeOrderForm);

    // In case we're modifying an order rejected because it was invalid
    updateTotal();
});


function updateTradeOrderForm() {
    currency = getSelectedCurrency();
    category = $("input:radio.category-select:checked").val();
    

    if (category) {
        if (category == "sell") {
            setBalance("BTC");
        }
        else {
            if (currency) {
                setBalance(currency);
            }
            else {
                $("#balance").val("");
            }
        }
    }
}

function getSelectedCurrency() {
    return($("input:radio.currency-select:checked").val());
}

function setBalance(currency) {
    $.get("/account/balance", {
            "currency" : currency
        },
        function(data) {
            balance = $("#balance").val(data + " " + currency);
        }
    );
}

function updateTotal() {
    precision = 5;
    currency = getSelectedCurrency();
    ppc = parseFloat($("#trade_order_ppc").val());
    amount = parseFloat($("#trade_order_amount").val());
    total = roundTo(ppc * amount, precision);

    if (!isNaN(total)) {
        total = (total.toFixed(precision).toString());
        
        if (currency) {
            total = total + " " + currency;
        }
    }
    else {
        total = "";
    }

    $("#total").val(total);
}

function roundTo(value, precision) {
    return((Math.round(value * Math.pow(10, precision))) / Math.pow(10, precision));
}









