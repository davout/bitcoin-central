$(document).ready(function() {
    // Triggered by a currency or category selection on
    // the trade order creation form
    // TODO : DRY this up with body class/id
    $("input.currency-select").click(function(e) {
        updateTradeOrderForm();
    });

    $("input.category-select").click(function(e) {
        updateTradeOrderForm();
    });
});


function updateTradeOrderForm() {
    currency = $("input:radio.currency-select:checked").val();
    category = $("input:radio.category-select:checked").val();
    

    if (category) {
        setLinksFor(category);

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

function setBalance(currency) {
    $.get("/user/balance", { "currency" : currency }, function(data) {
            balance = $("#balance").val(data + " " + currency);
        }
    );
}

function setLinksFor(category) {
    $(".js-calculation").each(function(idx, e) { $(e).hide(); });
    $(".js-calculation." + category).each(function(idx, e) { $(e).show(); });
}











