(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.App = {
    CanvasController: {},
    ImageProcessingEngine: {},
    FlameDiffProcessingEngine: {}
  };

  App.CanvasController = (function() {
    CanvasController.prototype.TimerPerSecond = 30;

    function CanvasController(video, canvas) {
      var _this = this;
      this.video = video;
      this.canvas = canvas;
      this.renderCanvas = __bind(this.renderCanvas, this);
      this.checkMedia();
      navigator.getUserMedia = navigator.webkitGetUserMedia || navigator.getUserMedia;
      window.URL = window.URL || window.webkitURL;
      this.ctx = this.canvas.getContext('2d');
      navigator.getUserMedia({
        video: true
      }, function(stream) {
        _this.localMediaStream = stream;
        return _this.video.src = window.URL.createObjectURL(_this.localMediaStream);
      }, function(err) {
        alert('error');
        return console.log(err);
      });
    }

    CanvasController.prototype.hasGetUserMedia = function() {
      return !!(navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia);
    };

    CanvasController.prototype.videoStart = function() {
      this.video.play();
      return this.timer = setInterval(this.renderCanvas, this.TimerPerSecond);
    };

    CanvasController.prototype.videoStop = function() {
      this.localMediaStream.stop();
      return clearInterval(this.timer);
    };

    CanvasController.prototype.getImageData = function() {
      return this.ctx.getImageData(0, 0, this.video.videoWidth, this.video.videoHeight);
    };

    CanvasController.prototype.renderCanvas = function() {
      this.canvas.height = this.video.videoHeight;
      this.canvas.width = this.video.videoWidth;
      this.ctx.drawImage(this.video, 0, 0);
      return this.ctx.putImageData(this.getProcessedImage(), 0, 0);
    };

    CanvasController.prototype.checkMedia = function() {
      if (this.hasGetUserMedia()) {
        return console.log('カメラOk');
      } else {
        return alert('カメラが使用できません');
      }
    };

    CanvasController.prototype.setEngine = function(imageEngine) {
      this.imageEngine = imageEngine;
    };

    CanvasController.prototype.getProcessedImage = function() {
      return this.imageEngine.execute(this.getImageData());
    };

    return CanvasController;

  })();

  App.ImageProcessingEngine = (function() {
    function ImageProcessingEngine(image) {
      this.width = image.width;
      this.height = image.height;
      this.imageData = image.data;
    }

    ImageProcessingEngine.prototype.execute = function() {
      return console.log('ok');
    };

    return ImageProcessingEngine;

  })();

  App.FlameDiffProcessingEngine = (function() {
    FlameDiffProcessingEngine.prototype.THRESHOULD = 200;

    FlameDiffProcessingEngine.prototype.PERPIXEL = 16;

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
      var data, diff, index, x, y, _i, _j, _ref, _ref1;
      diff = this.getDiff();
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

    FlameDiffProcessingEngine.prototype.execute = function(image) {
      this.setImage(image);
      return this.getProcessedImage();
    };

    return FlameDiffProcessingEngine;

  })();

  $(function() {
    var canvas, canvasController, video;
    video = $('#video')[0];
    canvas = $('#canvas')[0];
    canvasController = new App.CanvasController(video, canvas);
    canvasController.setEngine(new App.FlameDiffProcessingEngine());
    $('#start').click(function() {
      return canvasController.videoStart();
    });
    return $('#stop').click(function() {
      return canvasController.videoStop();
    });
  });

}).call(this);
