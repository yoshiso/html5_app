
class FlameDiffProcessingEngine

    THRESHOULD:250 #差分の閾値
    PERPIXEL:10

    # @params image CanvasのImageDataオブジェクト
    constructor: ->
        @target = []

    # @params image CanvasのImageDataオブジェクト
    setImage: (image)->
        @prevImage = @image || null
        @prevTarget = $.extend(true, {}, @target) || null

        @image = image
        @width = image.width
        @height = image.height

        @setTarget()

    getImage: ->
        @image

    #
    # 画像の中の対象とするピクセルをtargetとして保存する
    #
    setTarget: ->
        data = @image.data
        for x in [0..@width-1]
            @target[parseInt(x/@PERPIXEL)] ||= {}
            for y in [0..@height-1]
                # 対象pixelのindex（色情報があるので*@PERPIXELする)
                if x % @PERPIXEL == 0  and y % @PERPIXEL == 0
                    index = (x + y * @width) * 4
                    @target[parseInt(x/@PERPIXEL)][parseInt(y/@PERPIXEL)] = {}
                    @target[parseInt(x/@PERPIXEL)][parseInt(y/@PERPIXEL)][0] = data[index + 0]
                    @target[parseInt(x/@PERPIXEL)][parseInt(y/@PERPIXEL)][1] = data[index + 1]
                    @target[parseInt(x/@PERPIXEL)][parseInt(y/@PERPIXEL)][2] = data[index + 2]

    #
    # targetと1つ前のtargetを比較して差分をオブジェクトとして返す
    # @return diff[x][y]に差分の値が入る
    getDiff: ->
        if @prevTarget.length == 0
            return null
        diff = {}

        for x in [0..(@width/@PERPIXEL)-1]
            diff[x] ||= {}
            for y in [0..(@height/@PERPIXEL)-1]
                diff[x][y] = Math.abs(@target[x][y][0] - @prevTarget[x][y][0]) + Math.abs(@target[x][y][1] - @prevTarget[x][y][1]) + Math.abs(@target[x][y][2] - @prevTarget[x][y][2])
        return diff

    #
    # 差分を比較して異なっている部分を追加した画像を生成する
    #
    getProcessedImage:->
        #target pixelを差分比較
        diff = @getDiff()

        point = @getObjectPoint(diff)

        #閾値を超えるかどうか判別
        if diff
            #target pixelの支配する部分を塗りつぶす
            data = @image.data
            for x in [0..@width-1]
                for y in [0..@height-1]
                    # 対象pixelのindex（色情報があるので*@PERPIXELする）
                    if diff[parseInt(x / @PERPIXEL)][parseInt(y / @PERPIXEL)] >= @THRESHOULD
                        index = (x + y * @width) * 4
                        data[index + 0] = 0
                        data[index + 1] = 0
                        data[index + 2] = 0
                        data[index + 3] = 255
            @image.data = data
        return @image

    #
    # 閾値をベースとしてラベリング処理を行い、各ラベル付けされた物体のcenterのPointを返す
    # @params diff diffs[x][y] に差分の値の入ったオブジェクト
    #
    getObjectPoint:(diffs)->
        pont = []
        for xDiff in diffs
            for yDiff in xDiffs
                console.log()



    #
    # @params image CanvasのImageDataオブジェクト
    # @return image CanvasのImageDataオブジェクト
    #
    execute: (image)->
        @setImage(image)
        @getProcessedImage()




$(window).load ->

    canvas = $('#canvas')[0]
    result = $('#result')[0]
    ctx = canvas.getContext('2d')
    result_ctx = result.getContext('2d')
    img1 = $('#img1')[0]
    img2 = $('#img2')[0]

    #動きをプリテンドする

    ctx.drawImage(img1, 0, 0);
    imageData_img1 = ctx.getImageData(0, 0, canvas.width, canvas.height);

    ctx.drawImage(img2, 0, 0);
    imageData_img2 = ctx.getImageData(0, 0, canvas.width, canvas.height);

    engine = new FlameDiffProcessingEngine()

    engine.setImage(imageData_img1)
    engine.setImage(imageData_img2)

    #出力部分
    result_ctx.putImageData(engine.getProcessedImage(),0,0)
