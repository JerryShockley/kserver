// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require foundation
//= require foundation/foundation.accordion
//= require FWDRL
//= require_tree .
//= require turbolinks

// $(function() {
//   $(document).foundation();
// });

Foundation.global.namespace = '';




$(function(){ 
  $(document).foundation(); 
});

FWDRLUtils.onReady(function(){
  new FWDRL({
    //main settings
    mainFolderPath: "/assets/content",
    skinPath:"modern_skin_dark",
    facebookAppId:"",  //"213684265480896",//required only if the facebook share button is used
    rightClickContextMenu:"default",
    buttonsAlignment:"in",
    useDeepLinking:"yes",
    useAsModal:"no",
    slideShowAutoPlay:"no",
    addKeyboardSupport:"yes",
    showCloseButton:"yes",
    showFacebookButton:"yes",
    showZoomButton:"no",
    showSlideShowButton:"no",
    showSlideShowAnimation:"no",
    showNextAndPrevButtons:"yes",
    showNextAndPrevButtonsOnMobile:"yes",
    buttonsHideDelay:10,
    slideShowDelay:4,
    defaultItemWidth:640,
    defaultItemHeight:480,
    itemOffsetHeight:50,
    spaceBetweenButtons:8,
    buttonsOffsetIn:5,
    buttonsOffsetOut:5,
    itemBorderSize:4,
    itemBorderRadius:2,
    backgroundOpacity:.7,
    itemBoxShadow:"none",
    itemBackgroundColor:"#333333",
    itemBorderColor:"#FFFFFF",
    backgroundColor:"#000000",
    //thumbnails settings
    showThumbnails:"yes",
    showThumbnailsHideOrShowButton:"yes",
    showThumbnailsByDefault:"yes",
    showThumbnailsOverlay:"yes",
    showThumbnailsSmallIcon:"yes",
    thumbnailsHoverEffect:"scale",
    thumbnailsImageHeight:80,
    thumbnailsBorderSize:4,
    thumbnailsBorderRadius:0,
    spaceBetweenThumbnailsAndItem:0,
    thumbnailsOffsetBottom:0,
    spaceBetweenThumbnails:2,
    thumbnailsOverlayOpacity:.6,
    thumbnailsOverlayColor:"#000000",
    thumbnailsBorderNormalColor:"#FFFFFF",
    thumbnailsBorderSelectedColor:"#FFFFFF",
    //description settings
    descriptionWindowPosition:"bottom",
    showDescriptionButton:"yes",
    showDescriptionByDefault:"yes",
    descriptionWindowAnimationType:"motion",
    descriptionWindowBackgroundColor:"#FFFFFF",
    descriptionWindowBackgroundOpacity:.9,
    //video & audio players settings
    useVideo:"yes",
    useAudio:"no",
    videoShowFullScreenButton:"yes",
    addVideoKeyboardSupport:"yes",
    nextVideoOrAudioAutoPlay:"yes",
    videoAutoPlay:"no",
    videoLoop:"no",
    audioAutoPlay:"no",
    audioLoop:"no",
    videoControllerHideDelay:3,
    videoControllerHeight:41,
    audioControllerHeight:44,
    startSpaceBetweenButtons:7,
    vdSpaceBetweenButtons:9,
    mainScrubberOffestTop:14,
    scrubbersOffsetWidth:1,
    audioScrubbersOffestTotalWidth:4,
    timeOffsetLeftWidth:5,
    timeOffsetRightWidth:3,
    volumeScrubberWidth:80,
    volumeScrubberOffsetRightWidth:0,
    videoControllerBackgroundColor:"#FFFFFF",
    videoPosterBackgroundColor:"#0099FF",
    audioControllerBackgroundColor:"#FFFFFF",
    timeColor:"#000000"
  });
});
