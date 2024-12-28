function im()
    % Main GUI Window
    fig = figure('Name', 'Image Editor GUI', 'NumberTitle', 'off', ...
        'MenuBar', 'none', 'ToolBar', 'none', 'Resize', 'off', ...
        'Position', [100, 100, 800, 600]);

    % Components
    uicontrol('Style', 'text', 'Position', [20, 550, 120, 30], ...
        'String', 'Select Images:', 'HorizontalAlignment', 'left', 'FontSize', 10);
    
    uploadButton = uicontrol('Style', 'pushbutton', 'Position', [140, 550, 80, 30], ...
    'String', 'Upload', 'Callback', @uploadImages);

    % Sliders and Buttons
    
    resizeLabel = uicontrol('Style', 'text', 'Position', [20, 500, 150, 30], ...
        'String', 'Resize Factor (0.1 - 1):', 'HorizontalAlignment', 'left', 'FontSize', 10);

    resizeSlider = uicontrol('Style', 'slider', 'Position', [170, 510, 200, 20], ...
        'Min', 0.1, 'Max', 1, 'Value', 1, 'Callback', @resizeImage, 'Enable', 'off');

    grayscaleButton = uicontrol('Style', 'pushbutton', 'Position', [20, 450, 150, 30], ...
        'String', 'Convert to Grayscale', 'Callback', @convertToGrayscale, 'Enable', 'off');

    contrastLabel = uicontrol('Style', 'text', 'Position', [20, 400, 120, 30], ...
        'String', 'Adjust Contrast:', 'HorizontalAlignment', 'left', 'FontSize', 10);

    contrastSlider = uicontrol('Style', 'slider', 'Position', [170, 410, 200, 20], ...
        'Min', 0.5, 'Max', 2, 'Value', 1, 'Callback', @adjustContrast, 'Enable', 'off');

    heqButton = uicontrol('Style', 'pushbutton', 'Position', [20, 350, 150, 30], ...
        'String', 'Histogram Equalization', 'Callback', @histogramEqualization, 'Enable', 'off');

    adapthisteqButton = uicontrol('Style', 'pushbutton', 'Position', [20, 300, 200, 30], ...
        'String', 'Adaptive Hist Equalization', 'Callback', @adaptiveHistEq, 'Enable', 'off');

    % Additional Functionality Buttons
    flipHButton = uicontrol('Style', 'pushbutton', 'Position', [20, 250, 150, 30], ...
        'String', 'Flip Horizontally', 'Callback', @flipHorizontal, 'Enable', 'off');

    flipVButton = uicontrol('Style', 'pushbutton', 'Position', [180, 250, 150, 30], ...
        'String', 'Flip Vertically', 'Callback', @flipVertical, 'Enable', 'off');

    invertColorButton = uicontrol('Style', 'pushbutton', 'Position', [20, 200, 150, 30], ...
        'String', 'Invert Colors', 'Callback', @invertColors, 'Enable', 'off');

    watermarkButton = uicontrol('Style', 'pushbutton', 'Position', [180, 200, 150, 30], ...
        'String', 'Add Watermark', 'Callback', @addWatermark, 'Enable', 'off');

    histogramButton = uicontrol('Style', 'pushbutton', 'Position', [20, 150, 150, 30], ...
        'String', 'Show Histogram', 'Callback', @showHistogram, 'Enable', 'off');

    % Noise Controls
    addNoiseMenu = uicontrol('Style', 'popupmenu', 'Position', [20, 100, 150, 30], ...
        'String', {'None', 'Gaussian Noise', 'Salt & Pepper Noise'}, ...
        'Callback', @addNoise, 'Enable', 'off');

    removeNoiseButton = uicontrol('Style', 'pushbutton', 'Position', [180, 100, 150, 30], ...
        'String', 'Remove Noise', 'Callback', @removeNoise, 'Enable', 'off');

    % Sliders for Saturation, Rotation, and Brightness
    saturationSlider = uicontrol('Style', 'slider', 'Position', [20, 60, 300, 20], ...
        'Min', -1, 'Max', 1, 'Value', 0, 'Callback', @adjustSaturation, 'Enable', 'off');

    rotationSlider = uicontrol('Style', 'slider', 'Position', [20, 30, 300, 20], ...
        'Min', -180, 'Max', 180, 'Value', 0, 'Callback', @rotateImage, 'Enable', 'off');

    brightnessSlider = uicontrol('Style', 'slider', 'Position', [20, 0, 300, 20], ...
        'Min', -1, 'Max', 1, 'Value', 0, 'Callback', @adjustBrightness, 'Enable', 'off');

    % Undo and Save Buttons
    cropButton = uicontrol('Style', 'pushbutton', 'Position', [350, 150, 80, 30], ...
        'String', 'Crop', 'Callback', @cropImage, 'Enable', 'off');

    undoButton = uicontrol('Style', 'pushbutton', 'Position', [350, 100, 80, 30], ...
        'String', 'Undo', 'Callback', @undoChanges, 'Enable', 'off');

    saveButton = uicontrol('Style', 'pushbutton', 'Position', [350, 50, 80, 30], ...
        'String', 'Save Image', 'Callback', @saveImage, 'Enable', 'off');

    % Axes for Image Display
    originalAxes = axes('Parent', fig, 'Position', [0.55, 0.55, 0.4, 0.4]);
    title(originalAxes, 'Original Image');

    processedAxes = axes('Parent', fig, 'Position', [0.55, 0.05, 0.4, 0.4]);
    title(processedAxes, 'Processed Image');

    % Variables
    imgList = {};
    imgIndex = 1;
    img = [];
    processedImg = [];
    imgHistory = {};

    % Callback Functions
    function uploadImages(~, ~)
       [files, path] = uigetfile({'*.jpg;*.png;*.bmp', 'Image Files (*.jpg, *.png, *.bmp)'}, ...
                              'Select Images', 'MultiSelect', 'on');
    if iscell(files)
        imgList = fullfile(path, files);
    elseif ischar(files)
        imgList = {fullfile(path, files)};
    else
        msgbox('No image selected!', 'Error', 'error');
        return;
    end

    if ~isempty(imgList)
        imgIndex = 1;
        loadImage();
        enableControls();
        msgbox('Images uploaded successfully!', 'Success');
    end
    end

    function loadImage()
        img = imread(imgList{imgIndex});
        processedImg = img;
        imgHistory = {processedImg}; % Initialize history
        axes(originalAxes);
        imshow(img);
        title('Original Image');
        displayProcessedImage();
    end

    function enableControls()
        set([resizeSlider, grayscaleButton, contrastSlider, heqButton, adapthisteqButton, ...
            flipHButton, flipVButton, invertColorButton, watermarkButton, histogramButton, ...
            addNoiseMenu, removeNoiseButton, saturationSlider, rotationSlider, ...
            brightnessSlider, cropButton, undoButton, saveButton], 'Enable', 'on');
    end

    function saveToHistory()
        imgHistory{end+1} = processedImg; % Save current image to history
    end

    % Define processing functions: resize, grayscale, contrast, equalization, etc.
    function resizeImage(~, ~)
        resizeFactor = resizeSlider.Value;
        saveToHistory();
        processedImg = imresize(img, resizeFactor);
        set(resizeLabel, 'String', sprintf('Image resized by %.2fx', resizeFactor));
        displayProcessedImage();
    end

    function convertToGrayscale(~, ~)
        saveToHistory();
        processedImg = rgb2gray(processedImg);
        set(resizeLabel, 'String', 'Converted to Grayscale');
        displayProcessedImage();
    end

    function adjustContrast(~, ~)
        contrastFactor = contrastSlider.Value;
        saveToHistory();
        processedImg = imadjust(processedImg, stretchlim(processedImg), [], contrastFactor);
        set(contrastLabel, 'String', sprintf('Contrast adjusted: %.2fx', contrastFactor));
        displayProcessedImage();
    end

    function histogramEqualization(~, ~)
        saveToHistory();
        processedImg = histeq(rgb2gray(processedImg));
        set(resizeLabel, 'String', 'Histogram Equalization applied');
        displayProcessedImage();
    end

    function adaptiveHistEq(~, ~)
        saveToHistory();
        processedImg = adapthisteq(rgb2gray(processedImg));
        displayProcessedImage();
    end

    % Additional processing functions: flipping, color inversion, adding watermark
    function flipHorizontal(~, ~)
        saveToHistory();
        processedImg = flip(processedImg, 2);
        displayProcessedImage();
    end

    function flipVertical(~, ~)
        saveToHistory();
        processedImg = flip(processedImg, 1);
        displayProcessedImage();
    end

    function invertColors(~, ~)
        saveToHistory();
        processedImg = imcomplement(processedImg);
        displayProcessedImage();
    end

    function addWatermark(~, ~)
        saveToHistory();
        watermarkText = 'Watermark';
        position = [10, 10];
        processedImg = insertText(processedImg, position, watermarkText, 'FontSize', 18, ...
                                  'TextColor', 'white', 'BoxColor', 'black');
        displayProcessedImage();
    end

    function showHistogram(~, ~)
        figure, imhist(processedImg);
        title('Image Histogram');
    end

    function addNoise(~, ~)
        saveToHistory();
        noiseType = addNoiseMenu.Value;
        switch noiseType
            case 2
                processedImg = imnoise(processedImg, 'gaussian');
            case 3
                processedImg = imnoise(processedImg, 'salt & pepper');
        end
        displayProcessedImage();
    end

    function removeNoise(~, ~)
        saveToHistory();
        processedImg = medfilt2(processedImg);
        displayProcessedImage();
    end

    function adjustSaturation(~, ~)
        % Add saturation adjustment logic here
    end

    function rotateImage(~, ~)
        angle = rotationSlider.Value;
        saveToHistory();
        processedImg = imrotate(processedImg, angle, 'bilinear', 'crop');
        displayProcessedImage();
    end

    function adjustBrightness(~, ~)
        brightness = brightnessSlider.Value;
        saveToHistory();
        processedImg = imadjust(processedImg, [], [], brightness + 1);
        displayProcessedImage();
    end

    function cropImage(~, ~)
        saveToHistory();
        processedImg = imcrop(processedImg);
        displayProcessedImage();
    end

    function undoChanges(~, ~)
        if numel(imgHistory) > 1
            imgHistory(end) = []; % Remove the latest image from history
            processedImg = imgHistory{end}; % Set to the previous image
            displayProcessedImage();
        end
    end

    function saveImage(~, ~)
        [fileName, pathName] = uiputfile({'*.jpg', 'JPEG'; '*.png', 'PNG'; '*.bmp', 'BMP'}, ...
                                         'Save Image As');
        if fileName
            imwrite(processedImg, fullfile(pathName, fileName));
        end
    end

    % Function to display the processed image
    function displayProcessedImage()
        axes(processedAxes);
        imshow(processedImg);
        title('Processed Image');
    end
end
