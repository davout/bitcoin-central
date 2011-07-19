$(document).ready(function() {
    /* Trade order creation form */
    $("body.trade_orders .trigger-total-update").bind("click keypress keyup blur", updateTotal);

    if ($("body.trade_orders input#trade_order_amount").length) {
        updateTradeOrderForm();
    }

    // Triggered by a currency or category selection on
    // the trade order creation form
    $("body.trade_orders input.trigger-total-update").click(updateTradeOrderForm);
    
    $("body.transfers-new #transfer_currency").change(updateWithdrawForm)
    
    /* Logout count-down */
    $("span#countdown").show()
    
    delay = $('#countdown').data("delay")
    logoutPath = $('#countdown').data("logout-path")    
    
    var logout = new Date()
    logout.setSeconds(logout.getSeconds() + delay)
    
    $('#countdown').countdown({
        until: logout,
        compact: true,
        format: "%M:%S",
        layout: "({mnn}:{snn})",
        onExpiry: function() {
            window.location = logoutPath
        }
    })
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

function updateWithdrawForm(evt) {
   currency = evt.target.options[evt.target.selectedIndex].value 
   window.location = "/account/transfers/new?currency=" + currency
}

function roundTo(value, precision) {
    return((Math.round(value * Math.pow(10, precision))) / Math.pow(10, precision));
}