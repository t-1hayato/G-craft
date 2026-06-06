let testBlocks = [
    {type: 'text', content: 'hello'},
    {type: 'image', content: 'img1.jpg'},
    {type: 'image', content: 'img2.jpg'},
    {type: 'text', content: 'world'}
];
let html = '';
let imageGroup = [];

function flushImages() {
    if (imageGroup.length > 0) {
        html += '<div class=\"image-group\">' + imageGroup.map(src => '<img src=\"' + src + '\">').join('') + '</div>';
        imageGroup = [];
    }
}

testBlocks.forEach(b => {
    if (b.type === 'image') {
        imageGroup.push(b.content);
    } else {
        flushImages();
        html += '<p>' + b.content + '</p>';
    }
});
flushImages();
console.log(html);
