const productService = require("../services/productService");

const getProducts = (req, res) => {

    const products = productService.getProducts();

    res.json(products);

};

module.exports = {
    getProducts
};
