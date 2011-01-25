$(document).ready(function() {
    /* Trade order creation form */
    $("body.trade_orders .trigger-total-update").bind("click keypress keyup blur", updateTotal);

    if ($("body.trade_orders input#trade_order_amount").length) {
        updateTradeOrderForm();
    }

    // Triggered by a currency or category selection on
    // the trade order creation form
    $("body.trade_orders input.trigger-total-update").click(updateTradeOrderForm);


    /* Transfer creation form */
    $("body.transfers input.trigger-balance-update").click(
        function() {
            setBalance(getSelectedCurrency());
            updateTransferPayeeExplanation();
        }
    );

    if ($("body.transfers div#payee-explanation").length) {
        updateTransferPayeeExplanation();
    }
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

    updateTotal();
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

function updateTransferPayeeExplanation() {
    transferExplanations = {
        "EUR"   : "Bitcoin Central account or e-mail address",
        "LRUSD" : "Bitcoin Central, Liberty Reserve account or e-mail address",
        "LREUR" : "Bitcoin Central, Liberty Reserve account or e-mail address",
        "BTC"   : "Bitcoin Central account, e-mail or bitcoin address",
        "none"  : "Payee identification"
    }

    if (transferExplanations[getSelectedCurrency()]) {
        $("#payee-explanation").html(transferExplanations[getSelectedCurrency()]);
    }
    else {
        $("#payee-explanation").html(transferExplanations["none"]);
    }
}





