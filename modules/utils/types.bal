
public type Device record {
    string id?;
    string name;
    string imageUrl?;
    float price;
    string description?;
    string category;
    Promo? promos?;
};

public type Promo record {
    string id?;
    string promoCode;
    float discount;
};

public type UpdatePromoInDevicesRequest record {

    string addedPromoId;
    string removedPromoId;
};

public type UserPostModel record {
    string username;
    string password;
    string givenName;
    string familyName;
};
