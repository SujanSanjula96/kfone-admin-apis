
public type Device record {
    string id?;
    string name;
    string imageUrl?;
    float price;
    string description?;
    string category;
    Promo[]? promos;
};

public type Promo record {
    string id?;
    string promoCode;
    float discount;
};