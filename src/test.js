(function() {
  var FlameDiffProcessingEngine;

  FlameDiffProcessingEngine = (function() {
    FlameDiffProcessingEngine.prototype.THRESHOULD = 250;

    FlameDiffProcessingEngine.prototype.PERPIXEL = 10;

    function FlameDiffProcessingEngine() {
      this.target = [];
    }

    FlameDiffProcessingEngine.prototype.setImage = function(image) {
      this.prevImage = this.image || null;
      this.prevTarget = $.extend(true, {}, this.target) || null;
      this.image = image;
      this.width = image.width;
      this.height = image.height;
      return this.setTarget();
    };

    FlameDiffProcessingEngine.prototype.getImage = function() {
      return this.image;
    };

    FlameDiffProcessingEngine.prototype.setTarget = function() {
      var data, index, x, y, _base, _i, _name, _ref, _results;
      data = this.image.data;
      _results = [];
      for (x = _i = 0, _ref = this.width - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; x = 0 <= _ref ? ++_i : --_i) {
        (_base = this.target)[_name = parseInt(x / this.PERPIXEL)] || (_base[_name] = {});
        _results.push((function() {
          var _j, _ref1, _results1;
          _results1 = [];
          for (y = _j = 0, _ref1 = this.height - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = 0 <= _ref1 ? ++_j : --_j) {
            if (x % this.PERPIXEL === 0 && y % this.PERPIXEL === 0) {
              index = (x + y * this.width) * 4;
              this.target[parseInt(x / this.PERPIXEL)][parseInt(y / this.PERPIXEL)] = {};
              this.target[parseInt(x / this.PERPIXEL)][parseInt(y / this.PERPIXEL)][0] = data[index + 0];
              this.target[parseInt(x / this.PERPIXEL)][parseInt(y / this.PERPIXEL)][1] = data[index + 1];
              _results1.push(this.target[parseInt(x / this.PERPIXEL)][parseInt(y / this.PERPIXEL)][2] = data[index + 2]);
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    FlameDiffProcessingEngine.prototype.getDiff = function() {
      var diff, x, y, _i, _j, _ref, _ref1;
      if (this.prevTarget.length === 0) {
        return null;
      }
      diff = {};
      for (x = _i = 0, _ref = (this.width / this.PERPIXEL) - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; x = 0 <= _ref ? ++_i : --_i) {
        diff[x] || (diff[x] = {});
        for (y = _j = 0, _ref1 = (this.height / this.PERPIXEL) - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = 0 <= _ref1 ? ++_j : --_j) {
          diff[x][y] = Math.abs(this.target[x][y][0] - this.prevTarget[x][y][0]) + Math.abs(this.target[x][y][1] - this.prevTarget[x][y][1]) + Math.abs(this.target[x][y][2] - this.prevTarget[x][y][2]);
        }
      }
      return diff;
    };

    FlameDiffProcessingEngine.prototype.getProcessedImage = function() {
      var data, diff, index, point, x, y, _i, _j, _ref, _ref1;
      diff = this.getDiff();
      point = this.getObjectPoint(diff);
      if (diff) {
        data = this.image.data;
        for (x = _i = 0, _ref = this.width - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; x = 0 <= _ref ? ++_i : --_i) {
          for (y = _j = 0, _ref1 = this.height - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = 0 <= _ref1 ? ++_j : --_j) {
            if (diff[parseInt(x / this.PERPIXEL)][parseInt(y / this.PERPIXEL)] >= this.THRESHOULD) {
              index = (x + y * this.width) * 4;
              data[index + 0] = 0;
              data[index + 1] = 0;
              data[index + 2] = 0;
              data[index + 3] = 255;
            }
          }
        }
        this.image.data = data;
      }
      return this.image;
    };

    FlameDiffProcessingEngine.prototype.getObjectPoint = function(diffs) {
      var pont, xDiff, yDiff, _i, _len, _results;
      pont = [];
      _results = [];
      for (_i = 0, _len = diffs.length; _i < _len; _i++) {
        xDiff = diffs[_i];
        _results.push((function() {
          var _j, _len1, _results1;
          _results1 = [];
          for (_j = 0, _len1 = xDiffs.length; _j < _len1; _j++) {
            yDiff = xDiffs[_j];
            _results1.push(console.log());
          }
          return _results1;
        })());
      }
      return _results;
    };

    FlameDiffProcessingEngine.prototype.execute = function(image) {
      this.setImage(image);
      return this.getProcessedImage();
    };

    return FlameDiffProcessingEngine;

  })();

  $(window).load(function() {
    var canvas, ctx, engine, imageData_img1, imageData_img2, img1, img2, result, result_ctx;
    canvas = $('#canvas')[0];
    result = $('#result')[0];
    ctx = canvas.getContext('2d');
    result_ctx = result.getContext('2d');
    img1 = $('#img1')[0];
    img2 = $('#img2')[0];
    ctx.drawImage(img1, 0, 0);
    imageData_img1 = ctx.getImageData(0, 0, canvas.width, canvas.height);
    ctx.drawImage(img2, 0, 0);
    imageData_img2 = ctx.getImageData(0, 0, canvas.width, canvas.height);
    engine = new FlameDiffProcessingEngine();
    engine.setImage(imageData_img1);
    engine.setImage(imageData_img2);
    return result_ctx.putImageData(engine.getProcessedImage(), 0, 0);
  });

}).call(this);
