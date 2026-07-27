<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<html xmlns:v>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta HTTP-EQUIV="Pragma" CONTENT="no-cache">
<meta HTTP-EQUIV="Expires" CONTENT="-1">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<title><#Web_Title#> - <#menu5_6_3#></title>
<link rel="stylesheet" type="text/css" href="index_style.css">
<link rel="stylesheet" type="text/css" href="form_style.css">
<link rel="stylesheet" type="text/css" href="css/confirm_block.css">
<style>
.FormTable{
 	margin-top:10px;	
}	
.Bar_container{
	width:85%;
	height:21px;
	border:1px inset #999;
	margin:0 auto;
	margin-top:20px \9;
	background-color:#FFFFFF;
	z-index:100;
}
#proceeding_img_text{
	position:absolute; 
	z-index:101; 
	font-size:11px; color:#000000; 
	line-height:21px;
	width: 83%;
}
#proceeding_img{
 	height:21px;
	background: #D7E8F4;
	background: -webkit-linear-gradient(#F2F7EB 0%, #E4E6EE 49%, #C8D3Db 50%, #BACEDA 51%, #D7E8F4 100%);
	background: -o-linear-gradient(#F2F7EB 0%, #E4E6EE 49%, #C8D3Db 50%, #BACEDA 51%, #D7E8F4 100%);
	background: linear-gradient(#F2F7EB 0%, #E4E6EE 49%, #C8D3Db 50%, #BACEDA 51%, #D7E8F4 100%);
}
.button_helplink{
	font-weight: bolder;
	text-shadow: 1px 1px 0px black;
	text-align: center;
	vertical-align: middle;
	background: #121C1E;
	background: -webkit-linear-gradient(#233438 0%, #0F1011 100%);
	background: -o-linear-gradient(#233438 0%, #0F1011 100%);
	background: linear-gradient(#233438 0%, #0F1011 100%);
	-webkit-border-radius: 8px;
	-moz-border-radius: 8px;
	border-radius: 8px;
	border:0;
	color: #FFFFFF;
	height:33px;
	width:122px;
	font-family:Verdana;
	font-size:12px;
	overflow:visible;
	cursor:pointer;
	outline: none; /* for Firefox */
	hlbr:expression(this.onFocus=this.blur()); /* for IE */
	white-space:normal;
}
.button_helplink:hover{
	font-weight: bolder;
	background: #085F96;
	background: -webkit-linear-gradient(#09639C 0%, #003047 100%);
	background: -o-linear-gradient(#09639C 0%, #003047 100%);
	background: linear-gradient(#09639C 0%, #003047 100%);
	height:33px;
 	width:122px;
	cursor:pointer;
	outline: none; /* for Firefox */
 	hlbr:expression(this.onFocus=this.blur()); /* for IE */
}
.current_fw_release_note {
		color: #FC0;
        text-decoration: underline;
        cursor: pointer;
}
</style>
<script type="text/javascript" src="/js/jquery.js"></script>
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/help.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script language="JavaScript" type="text/javascript" src="/validator.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
<script language="JavaScript" type="text/javascript" src="/js/confirm_block.js"></script>
<script language="JavaScript" type="text/javascript" src="/switcherplugin/jquery.iphone-switch.js"></script>
<script language="JavaScript" type="text/javascript" src="/form.js"></script>
<script language="JavaScript" type="text/javascript" src="/js/httpApi.js"></script>
<script language="JavaScript" type="text/javascript" src="/js/asus_policy.js"></script>
<!-- script language="JavaScript" type="text/javascript" src="/ajax/get_rbk_info.asp"></script -->
<script language="JavaScript" type="text/javascript" src="/replaceisp.js"></script>
<script>
$(function () {
	if(amesh_support && (isSwMode("rt") || isSwMode("ap")) && ameshRouter_support) {
		addNewCSS('/device-map/amesh.css');
	}
});
var webs_state_update = '<% nvram_get("webs_state_update"); %>';
var webs_state_upgrade = '<% nvram_get("webs_state_upgrade"); %>';
var webs_state_error = '<% nvram_get("webs_state_error"); %>';
var webs_state_info = '<% nvram_get("webs_state_info"); %>';
var webs_state_REQinfo = '<% nvram_get("webs_state_REQinfo"); %>';
var webs_state_flag = '<% nvram_get("webs_state_flag"); %>';

var confirm_show = '<% get_parameter("confirm_show"); %>';
var nt_flag = '<% get_parameter("flag"); %>';
var webs_release_note= "";

var fwdl_percent="";
var varload = 0;
var helplink = "";
helplink = get_helplink();
var Downloadlink = "";
Downloadlink = get_Downloadlink();
var faq_href1 = "https://nw-dlcdnet.asus.com/support/forward.html?model=&type=Faq&lang="+ui_lang+"&kw=&num=131";
var faq_href2 = "https://nw-dlcdnet.asus.com/support/forward.html?model=&type=Faq&lang="+ui_lang+"&kw=&num=107";

var is_ISP_incompatible = (in_territory_code("CX/01") || in_territory_code("CX/02") || in_territory_code("CX/03") || in_territory_code("CX/05") || in_territory_code("CX/06")
						|| in_territory_code("CT/01") || in_territory_code("CT/02") || in_territory_code("CT/03") || in_territory_code("CT/04") || in_territory_code("CT/05")
						|| in_territory_code("CH/01"));

var dpi_engine_status = <%bwdpi_engine_status();%>;
var sig_ver = '<% nvram_get("bwdpi_sig_ver"); %>';
var sig_ver_ori = '<% nvram_get("bwdpi_sig_ver"); %>';
var sig_update_t = '<% nvram_get("sig_update_t"); %>';
if(cfg_sync_support){
	var cfg_check = '<% nvram_get("cfg_check"); %>';
	var cfg_upgrade = '<% nvram_get("cfg_upgrade"); %>';
}
if(pipefw_support || urlfw_support){
	var hndwr_status = '<% nvram_get("hndwr"); %>';
}

var webs_update_enable_orig = httpApi.nvramGet(["webs_update_enable"],1).webs_update_enable;
var webs_update_time_orig = httpApi.nvramGet(["webs_update_time"],1).webs_update_time;

var update_time_hour_orig = webs_update_time_orig.split(":")[0].replace(/^0/, '');
update_time_hour_orig = (update_time_hour_orig=="")? "2":update_time_hour_orig;

var update_time_min_orig = (webs_update_time_orig.split(":").length==2)? webs_update_time_orig.split(":")[1].replace(/^0/, ''):"";
update_time_min_orig = (update_time_min_orig=="")? "0":update_time_min_orig;

var amesh_offline_flag = false;
var interval_update_AiMesh_fw_status;

var firmver = '<% nvram_get("firmver"); %>';
var buildno = '<% nvram_get("buildno"); %>';
var extendno = '<% nvram_get("extendno"); %>';
var FWString = '';
FWString = firmver+"."+buildno;
FWString += "_"+extendno;

if(gobi_support){
	var mobile_upgrade_md5 = "";
	var mobile_upgrade_name = "";
	var mobile_upgrade_process = "";
	var mobile_upgrade_now = "";
	var mobile_upgrade_status = "";
}

var dl_path="https://dlcdnets.asus.com/pub/ASUS/";
var dl_beta="LiveUpdate/Release/Wireless_SQ/";
var dl_file="wireless/ASUSWRT/";
var frsmodel =  (httpApi.nvramGet(["webs_state_odm"]).webs_state_odm != "")? httpApi.nvramGet(["webs_state_odm"]).webs_state_odm:httpApi.nvramGet(["productid"]).productid;
var firmver_org =  httpApi.nvramGet(["firmver_org"]).firmver_org;
var buildno_org =  httpApi.nvramGet(["buildno_org"]).buildno_org;
var extendno_org =  httpApi.nvramGet(["extendno_org"]).extendno_org;
var revert_link='';
var RevertFWver = '';
var RevertFWString = '';
var isSame_org = false;
var isUnderREQ = false;
if(firmver_org!="" && buildno_org!="" && extendno_org!=""){
	RevertFWver = firmver_org+"."+buildno_org+"_"+extendno_org;
	isSame_org = (RevertFWver==FWString)? true:false;
	isUnderREQ = checkUnderREQ();
	RevertFWString = firmver_org.replace(/\./g,'')+"_"+buildno_org+"_"+extendno_org;
	RevertFWString = frsmodel+"_"+RevertFWString+"_rsa.zip";
	if(firmver_org.substring(0,1)=="9"){
		revert_link = dl_path+dl_beta+RevertFWString;
	}
	else{
		revert_link = dl_path+dl_file+RevertFWString;
	}
}
if(support_site_modelid == "GT-AC2900_SH"){
	afwupg_support=false;
	betaupg_support=false;
	revertfw_support=false;
}

function checkUnderREQ(){
	if(webs_state_REQinfo==""){
		return false;
	}
	else{
		var REQ_firmver=webs_state_REQinfo.split("_")[0];
		var REQ_buildno=webs_state_REQinfo.split("_")[1];
		var REQ_extendno=webs_state_REQinfo.split("_")[2];
		//alert("REQ: "+REQ_firmver+"_"+REQ_buildno+"_"+REQ_extendno+" | org: "+firmver_org+"_"+buildno_org+"_"+extendno_org);
		if((buildno_org < REQ_buildno) || 
			(buildno_org == REQ_buildno && firmver_org.replace(/\./g,'') < REQ_firmver) || 
			(buildno_org == REQ_buildno && firmver_org.replace(/\./g,'') == REQ_firmver && extendno_org < REQ_extendno)
		){
			return true;
		}
		else{
			return false;		
		}
	}
}

function showclock(){
	JS_timeObj.setTime(systime_millsec);
	systime_millsec += 1000;
	JS_timeObj2 = JS_timeObj.toString();
	JS_timeObj2 = JS_timeObj2.substring(0,3) + ", " +
	              JS_timeObj2.substring(4,10) + "  " +
				  checkTime(JS_timeObj.getHours()) + ":" +
				  checkTime(JS_timeObj.getMinutes()) + ":" +
				  checkTime(JS_timeObj.getSeconds()) + "  " +
				  /*JS_timeObj.getFullYear() + " GMT" +
				  timezone;*/ // Viz remove GMT timezone 2011.08
				  JS_timeObj.getFullYear();
	document.getElementById("system_time").innerHTML = JS_timeObj2;
	setTimeout("showclock()", 1000);
	if(navigator.appName.indexOf("Microsoft") >= 0)
		document.getElementById("textarea").style.width = "99%";
}
function showDST(){
	var system_timezone_dut = "<% nvram_get("time_zone"); %>";
	if(system_timezone_dut.search("DST") >= 0 && "<% nvram_get("time_zone_dst"); %>" == "1"){
		document.getElementById('dstzone').style.display = "";
		document.getElementById('dstzone').innerHTML = "<#General_x_SystemTime_dst#>";
	}
}
function load_time_hour(){
	free_options(document.form.webs_update_time_x_hour);
	var j;
	for(var i = 0; i < 24; i++){
		if(i<10){
			j="0"+i;
			add_option(document.form.webs_update_time_x_hour, j, i, (i == update_time_hour_orig));
		}
		else
			add_option(document.form.webs_update_time_x_hour, i, i, (i == update_time_hour_orig));
	}
}
function load_time_min(){
	free_options(document.form.webs_update_time_x_min);
	var j;
	for(var i = 0; i < 60; i++){
		if(i<10){
			j="0"+i;
			add_option(document.form.webs_update_time_x_min, j, i, (i == update_time_min_orig));
		}
		else
			add_option(document.form.webs_update_time_x_min, i, i, (i == update_time_min_orig));
	}
}
function save_update_enable(flag){
	var hour_tmp="02";
	var min_tmp="00";
	
	if(flag=="on")
		document.firmware_form.webs_update_enable.value = 1;
	else if(flag=="off")
		document.firmware_form.webs_update_enable.value = 0;

	if(document.firmware_form.webs_update_enable.value==1){
		hour_tmp = (document.form.webs_update_time_x_hour.value.length==1)? "0"+document.form.webs_update_time_x_hour.value : document.form.webs_update_time_x_hour.value;
		min_tmp = (document.form.webs_update_time_x_min.value.length==1)? "0"+document.form.webs_update_time_x_min.value : document.form.webs_update_time_x_min.value;
	
		document.firmware_form.webs_update_time.value = hour_tmp+":"+min_tmp;
	}
	else
		document.firmware_form.webs_update_time.disabled = true;
			
	document.firmware_form.submit();
	if(flag == "on" || flag == "off"){
		setTimeout("refreshpage()", 500);
	}
}
function change_beta_path(flag){
	
	document.firmware_form.webs_update_beta.value = (document.form.check_beta.checked)? 1:0;
	document.firmware_form.webs_update_ts.value = "";
	document.firmware_form.submit();
}

function initial(){
	show_menu();
	showDST();

	// Show firmware version only (MT798X UBI layout - no web firmware upgrade)
	$("#FWString").append("<span style='color:#FFFFFF;'>"+FWString+"</span>");

	// Hide all upgrade-related elements
	$("table").remove("#auto_upgrade_setting");
	$("table").remove("#secur_stab_setting");
	$("#sig_ver_field").hide();
	$("#update_div").hide();
	$("#check_beta_div").hide();
	$("#linkpage_div").hide();
	$("#check_states").hide();
	$("#manually_upgrade_tr").hide();
	$("#modem_fw_upgrade").hide();
	$(".aimesh_manual_fw_update_hint").hide();

	// Hide firmware upgrade notes (not applicable for UBI layout)
	$("#fw_note2").hide();
	$("#fw_note3").hide();
	$("#fw_note5").hide();

	// Hide AiMesh related elements
	$("#fw_tr").hide();

	// Language selection for U-Boot recovery instructions
	if(document.form.preferred_lang.value == "CN") {
		$(".uboot_lang_en").hide();
	} else {
		$(".uboot_lang_cn").hide();
	}

	// Show U-Boot recovery instructions
	$("#uboot_recovery_section").show();
}

function replace_isp_name(_str){
	var updated_declaration = _str;
	var isp_name = "";
	if(isp_json[ttc]){
		if(document.form.preferred_lang.value=="TW"){
			isp_name = isp_json[ttc].ISP_TW;
		}
		else if(document.form.preferred_lang.value=="CN"){
			isp_name = isp_json[ttc].ISP_CN;
		}
		else{
			isp_name = isp_json[ttc].ISP_US;
		}
		updated_declaration = updated_declaration.replace("%@", isp_name);
	}

	return updated_declaration;
}

var dead = 0;
var note_display=0;	//formal path
function detect_firmware(flag){
	$.ajax({
		url: '/detect_firmware.asp',
		dataType: 'script',
		error: function(xhr){
			dead++;
			if(dead < 30)
				setTimeout("detect_firmware();", 1000);
			else{
  				document.getElementById('update_scan').style.display="none";
  				document.getElementById('update_states').innerHTML="<#info_failed#>&nbsp;<#FW_n4#>";
				document.getElementById("faq_link2").href=faq_href2;
				document.getElementById('update').disabled = false;
			}
		},

		success: function(){
			if(cfg_sync_support){
				if(cfg_check == "" || cfg_check == "0" || cfg_check == "1" || cfg_check == "5"){
					setTimeout("detect_firmware();", 1000);
				}
				else{	// got fw info
					if(cfg_check == "2" || cfg_check == "3"){
						document.getElementById('update_scan').style.display="none";
						document.getElementById('update_states').innerHTML="<#info_failed#>&nbsp;<#FW_n4#>";
						document.getElementById("faq_link2").href=faq_href2;
						document.getElementById('update').disabled = false;
					}
					else if(cfg_check == "7" || cfg_check == "9"){
						document.getElementById('update_scan').style.display="none";
						document.getElementById('update_states').innerHTML="";
						document.getElementById('update').disabled = false;
						var check_webs_state_info = webs_state_info;						
						note_display=0;
												
						if(amesh_support && (isSwMode("rt") || isSwMode("ap")) && ameshRouter_support)
							show_amas_fw_result();
						else
							do_show_confirm(webs_state_flag);
					}
				}
			}
			else{
				if(webs_state_update == "0"){
					setTimeout("detect_firmware();", 1000);
				}
				else{	// got fw info
					if(webs_state_error == "1"){	//1:wget fail
						document.getElementById('update_scan').style.display="none";
						document.getElementById('update_states').innerHTML="<#info_failed#>&nbsp;<#FW_n4#>";
						document.getElementById("faq_link2").href=faq_href2;
						document.getElementById('update').disabled = false;
					}
					else if(webs_state_error == "3"){	//3: FW check/RSA check fail
						document.getElementById('update_scan').style.display="none";
						document.getElementById('update_states').innerHTML="<#FIRM_fail_desc#><br><#FW_desc1#>";
						document.getElementById('update').disabled = false;

					}
					else{
						document.getElementById('update_scan').style.display="none";
						document.getElementById('update_states').innerHTML="";
						document.getElementById('update').disabled = false;
						var check_webs_state_info = webs_state_info;
						note_display=0;
						
						do_show_confirm(webs_state_flag);
					}
				}
			}
		}
	});
}

function do_show_confirm(flag){

					if(flag==1 || flag==2){
						document.getElementById('update_scan').style.display="none";
						document.getElementById('update_states').style.display="none";

						confirm_asus({
         					title: "New Firmware Available",
         					contentA: "<#exist_new#><br>",
         					contentC: "<br><#ADSL_FW_note#> <#Main_alert_proceeding_desc5#>",
         					left_button: (flag==2)? "<#CTL_UpgradeNight#>":"<#CTL_Cancel#>",
         					left_button_callback: function(){confirm_cancel();},
         					left_button_args: {},
         					right_button: (flag==2)? "<#CTL_UpgradeNow#>":"<#CTL_upgrade#>",
							right_button_callback: function(){
										if(cfg_sync_support){
											cfgsync_firmware_upgrade();
										}
										else{
											document.start_update.action_mode.value="apply";
											document.start_update.action_script.value="stop_upgrade;start_webs_upgrade";
											document.start_update.submit();
										}
									},
         					right_button_args: {},
         					iframe: "get_release_note0.asp",
         					margin: "100px 0px 0px 25px",
         					note_display_flag: note_display
     					});
     					
					}
					else{
						document.getElementById('update_scan').style.display="none";
						document.getElementById('update_states').style.display="";
						document.getElementById('update_states').innerHTML="<#is_latest#>";
					}

}

function cfgsync_firmware_check(){
	$.ajax({
			url: '/apply.cgi?action_mode=firmware_check',
			dataType: 'script',
			error: function(xhr) {
				setTimeout("cfgsync_firmware_check();", 1000);
			},

			success: function(response){
				setTimeout("detect_firmware();", 5000);
			}
	});
}

function cfgsync_firmware_upgrade(){
	$.ajax({
			url: '/apply.cgi?action_mode=firmware_upgrade',
			dataType: 'script',
			error: function(xhr) {
				setTimeout("cfgsync_firmware_upgrade();", 1000);
			},

			success: function(response){
				setTimeout("startDownloading();", 1000);
			}
	});
}

function detect_update(){
	var download_info = 0;
	if(sw_mode != "1" || (link_status == "2" && link_auxstatus == "0") || (link_status == "2" && link_auxstatus == "2")){
		
		download_info++;
	}
	else if(dualwan_enabled &&
				((first_link_status == "2" && first_link_auxstatus == "0") || (first_link_status == "2" && first_link_auxstatus == "2")) ||
				((secondary_link_status == "2" && secondary_link_auxstatus == "0") || (secondary_link_status == "2" && secondary_link_auxstatus == "2"))){

		download_info++;
	}		
	else{
		document.getElementById('update_scan').style.display="none";
		document.getElementById('update_states').style.display="";
		document.getElementById('update_states').innerHTML="<#connect_failed#>";
		return false;	
	}

	if(download_info > 0){
		document.getElementById('update_states').style.display="";
		document.getElementById('update_states').innerHTML="<#check_proceeding#>";
		document.getElementById('update_scan').style.display="";
		document.getElementById('update').disabled = true;
		if(cfg_sync_support){
			cfgsync_firmware_check();
		}
		else{
			document.start_update.action_mode.value="apply";
			document.start_update.webs_update_trigger.value="FWUG";
			document.start_update.action_script.value="start_webs_update";
			document.start_update.submit();
		}
	}
}

var dead = 0;
function detect_httpd(){
	$.ajax({
		url: '/httpd_check.xml',
		dataType: 'xml',
		timeout: 1500,
		error: function(xhr){
			if(dead > 5){
				document.getElementById('loading_block1').style.display = "none";
				document.getElementById('loading_block2').style.display = "none";
				document.getElementById('loading_block3').style.display = "";
				document.getElementById('loading_block3').innerHTML = "<div><#FIRM_reboot_manually#></div>";
			}
			else{
				dead++;
			}

			setTimeout("detect_httpd();", 1000);
		},

		success: function(){
			location.href = "/";
		}
	});
}

var rebooting = 0;
function isDownloading(){
	$.ajax({
    		url: '/ajax_fwdl_percent.asp',
    		dataType: 'script',
				timeout: 1500,
    		error: function(xhr){
					
					rebooting++;
					if(rebooting < 30){
							setTimeout("isDownloading();", 1000);
					}
					else{
							document.getElementById("drword").innerHTML = "<#connect_failed#>";
							return false;
					}

    		},
    		success: function(){

				if(cfg_sync_support){

					if(cfg_check == "7") {
						if(cfg_upgrade == "1" || cfg_upgrade == "6" || cfg_upgrade == "8"){
							document.getElementById("drword").innerHTML = "&nbsp;&nbsp;&nbsp;<#fw_downloading#>...";
							setTimeout("isDownloading();", 1000);
						}
					}
					else if(cfg_check == "0") {
						if(cfg_upgrade == "2" || cfg_upgrade == "3"){
							document.getElementById("drword").innerHTML = "<#connect_failed#>";
							return false;
						}
						else if(cfg_upgrade == "4"){
							document.getElementById("drword").innerHTML = "<#FIRM_fail_desc#><br><#FW_desc1#>";
							return false;
						}
						else if(cfg_upgrade == "10"){		// start upgrading
							document.getElementById("hiddenMask").style.visibility = "hidden";
							if(pipefw_support || urlfw_support){
								showLoadingBar(120);
								setTimeout("detect_httpd();", 122000);
								return false;
							}
							else{
								showLoadingBar(270);
								setTimeout("detect_httpd();", 272000);
								return false;
							}
						}
					}
				}
				else{
					if(webs_state_upgrade == 0){
						document.getElementById("drword").innerHTML = "&nbsp;&nbsp;&nbsp;<#fw_downloading#>..."+fwdl_percent;
						setTimeout("isDownloading();", 1000);
					}
					else{ 	// webs_upgrade.sh is done
						
						if(webs_state_error == 1){
							document.getElementById("drword").innerHTML = "<#connect_failed#>";
							return false;
						}
						else if(webs_state_error == 2){
							document.getElementById("drword").innerHTML = "Memory space is NOT enough to upgrade on internet. Please wait for rebooting.<br><#FW_desc1#>";	/* untranslated */ //Untranslated.	fw_size_higher_mem
							return false;
						}
						else if(webs_state_error == 3){
							document.getElementById("drword").innerHTML = "<#FIRM_fail_desc#><br><#FW_desc1#>";
							return false;
						}
						else{		// start upgrading
							document.getElementById("hiddenMask").style.visibility = "hidden";

							if(pipefw_support || urlfw_support){
								document.start_update.flag.value="";
								document.start_update.action_mode.value="apply";
								document.start_update.action_script.value="reboot";
								document.start_update.submit();
								showLoadingBar(120);
								setTimeout("detect_httpd();", 122000);
								return false;
							}
							else{
								showLoadingBar(270);
								setTimeout("detect_httpd();", 272000);
								return false;
							}
						}

					}
				}
  			}
  		});
}

function startDownloading(){
	disableCheckChangedStatus();			
	dr_advise();
	document.getElementById("drword").innerHTML = "&nbsp;&nbsp;&nbsp;<#fw_downloading#>...";
	isDownloading();
}

var revert_rebooting = 0;
function isRevertDownloading(){
	$.ajax({
    		url: '/ajax_fwdl_percent.asp',
    		dataType: 'script',
			timeout: 1500,
    		error: function(xhr){
					
					revert_rebooting++;
					if(revert_rebooting < 30){
						setTimeout("isRevertDownloading();", 1000);
					}
					else{
						document.getElementById("drword").innerHTML = "<#connect_failed#>";
						return false;
					}

    		},
    		success: function(){

					if(webs_state_upgrade == 0){
						document.getElementById("drword").innerHTML = "&nbsp;&nbsp;&nbsp;<#fw_downloading#>..."+fwdl_percent;
						setTimeout("isRevertDownloading();", 1000);
					}
					else{ 	// webs_upgrade.sh is done
						if(webs_state_error == 1){
							document.getElementById("drword").innerHTML = "<#connect_failed#>";
							return false;
						}
						else if(webs_state_error == 2){
							document.getElementById("drword").innerHTML = "Memory space is NOT enough to upgrade on internet. Please wait for rebooting.<br><#FW_desc1#>";	/* untranslated */ //Untranslated.	fw_size_higher_mem
							return false;
						}
						else if(webs_state_error == 3){
							document.getElementById("drword").innerHTML = "<#FIRM_fail_desc#><br><#FW_desc1#>";
							return false;
						}
						else{		// start upgrading
							document.getElementById("hiddenMask").style.visibility = "hidden";

							if(pipefw_support || urlfw_support){
								document.start_update.flag.value="";
								document.start_update.action_mode.value="apply";
								document.start_update.action_script.value="reboot";
								document.start_update.submit();
								showLoadingBar(120);
								setTimeout("detect_httpd();", 122000);
								return false;
							}
							else{
								showLoadingBar(270);
								setTimeout("detect_httpd();", 272000);
								return false;
							}
						}

					}
  			}
  		});
}

function startRevertDownloading(){
	disableCheckChangedStatus();			
	dr_advise();
	document.getElementById("drword").innerHTML = "&nbsp;&nbsp;&nbsp;<#fw_downloading#>...";
	isRevertDownloading();
}

function check_zip(obj){
	var reg = new RegExp("^.*.(zip|ZIP|rar|RAR|7z|7Z)$", "gi");
	if(reg.test(obj.value)){
			alert("<#FW_note_unzip#>");
			obj.focus();
			obj.select();
			return false;
	}
	else
			return true;		
}

function submitForm(){
	if(!check_zip(document.form.file))
			return;
	else {
		var status = onSubmitCtrlOnly(document.form.upload, 'Upload1');
		if(amesh_support && status && (isSwMode("rt") || isSwMode("ap")) && ameshRouter_support) {
			if(interval_update_AiMesh_fw_status) {
				clearInterval(interval_update_AiMesh_fw_status);
				interval_update_AiMesh_fw_status = false;
			}
		}
	}
}

function sig_version_check(){
	document.getElementById("sig_check").disabled = true;
	$("#sig_status").show();
	document.sig_update.submit();
	$("#sig_status").html("<#sig_checking#>");
	document.getElementById("sig_update_scan").style.display = "";
	setTimeout("sig_check_status();", 8000);
}

var sdead=0;
var sig_chk_count=60;
function sig_check_status(){
	$.ajax({
    	url: '/detect_firmware.asp',
    	dataType: 'script',
    	timeout: 3000,
    	error:	function(xhr){
			sdead++;
			if(sdead < 20){
				setTimeout("sig_check_status();", 1000);
			}
			else{
				return;
			}
    		},
    	success: function(){
			--sig_chk_count;
			$("#sig_status").show();
			if(sig_state_flag == 0 && sig_state_error == 0 && sig_state_update == 1){		// no need upgrade
				$("#sig_status").html("<#sig_up2date#>");
				document.getElementById("sig_update_scan").style.display = "none";
				document.getElementById("sig_check").disabled = false;
			}
			else{
				if(sig_state_error != 0){		// update error
					$("#sig_status").html("<#sig_failed#>");
					document.getElementById("sig_update_scan").style.display = "none";
					document.getElementById("sig_check").disabled = false;
				}
				else{
					if(sig_state_flag == 1 && sig_state_update == 0 && sig_state_upgrade == 1){		//update complete
						update_sig_ver();
					}
					else{		//updating
						if(sig_chk_count < 1){
							$("#sig_status").hide();
							document.getElementById("sig_update_scan").style.display = "none";
							document.getElementById("sig_check").disabled = false;
						}
						else{
							$("#sig_status").html("<#sig_updating#>");
							setTimeout("sig_check_status();", 1000);
						}
					}
				}
			}
  		}
  	});
}

function update_sig_ver(){
	$.ajax({
    	url: '/detect_firmware.asp',
    	dataType: 'script',
		timeout: 3000,
    	error:	function(xhr){
    		setTimeout('update_sig_ver();', 1000);
    	},
    	success: function(){
		if(sig_ver == sig_ver_ori){
			setTimeout("update_sig_ver();", 1000);
		}
		else{
			document.getElementById("sig_update_date").innerHTML = "";
			document.getElementById("sig_update_scan").style.display = "none";
			document.getElementById("sig_check").disabled = false;
			$("#sig_status").html("<#sig_completed#>");
			$("#sig_ver_word").html(sig_ver);
		}
	}
  	
	});
}

function hide_upgrade_opt(flag){

	document.form.webs_update_time_x_hour.value = update_time_hour_orig;  
	document.form.webs_update_time_x_min.value = update_time_min_orig;
	(flag == 1) ? inputCtrl(document.form.webs_update_time_x_hour,1) : inputCtrl(document.form.webs_update_time_x_hour,0);
	(flag == 1) ? inputCtrl(document.form.webs_update_time_x_min,1) : inputCtrl(document.form.webs_update_time_x_min,0);
}

function getfirmwareTimeRange(str, pos)
{
	if (pos == 0)
		return str.substring(7,9);
	else if (pos == 1)
		return str.substring(9,11);
}

function setfirmwareTimeRange(rd, rh, rm)
{
	return(rd.value+rh.value+rm.value);
}

function validForm(){
	
	if(document.form.webs_update_time_x_hour.value.length==0){
		alert("<#JS_fieldblank#>");
		document.form.webs_update_time_x_hour.focus();
		return false;
	}
	if(document.form.webs_update_time_x_min.value.length==0){
		alert("<#JS_fieldblank#>");
		document.form.webs_update_time_x_min.focus();
		return false;
	}	

	return true;
}

function transferTimeFormat(time){
	if(time == 0){
		return "";
	}

	var t = new Date();
	t.setTime(time);
	var year = t.getFullYear();
	var month = t.getMonth() + 1;
	if(month < 10){
		month  = "0" + month;
	}
	
	var date = t.getDate();
	if(date < 10){
		date = "0" + date;
	}
	
	var hour = t.getHours();
	if(hour < 10){
		hour = "0" + hour;
	}
			
	var minute = t.getMinutes();
	if(minute < 10){
		minute = "0" + minute;
	}

	var date_format = "<#FW_updated#> : " + year + "/" + month + "/" + date + " " + hour + ":" + minute;
	return date_format;
}

function show_offline_msg(_checkFlag) {
	if(!amesh_offline_flag && _checkFlag) {
		$("#amas_update").css("display", "none");
		$(".checkNewFW").css("display", "none");
		$(".checkFWResult").empty();
		$(".checkFWResult").removeClass("aimesh_fw_release_note");
		detect_update();
		return;
	}

	var $offlineHtml = $('<div>');
	$offlineHtml.attr({"id" : "amesh_offline_msg"});
	$offlineHtml.addClass("amesh_popup_bg");
	$offlineHtml.css("display", "none");
	$offlineHtml.attr({"onselectstart" : "return false"});
	$offlineHtml.appendTo($('body'));

	var $amesh_hint_offline = $('<div>');
	$amesh_hint_offline.addClass("amesh_hint_text");
	$amesh_hint_offline.css("color", "#FC0");
	$amesh_hint_offline.html("<#FW_note_AiMesh_offline#>");
	$offlineHtml.append($amesh_hint_offline);

	var $amesh_hint_text = $('<div>');
	$amesh_hint_text.addClass("amesh_hint_text");
	$amesh_hint_text.html("<#AiMesh_OfflineTips#> :");
	$offlineHtml.append($amesh_hint_text);

	var $amesh_hint_content = $('<div>');
	$amesh_hint_content.addClass("amesh_hint_text");
	$amesh_hint_content.css("margin-left", "auto");
	$offlineHtml.append($amesh_hint_content);

	var $msg_item =  $('<ol>');
	var msg_text = "<li><#AiMesh_OfflineTips1#></li>";
	msg_text += "<li><#AiMesh_OfflineTips2#></li>";
	msg_text += "<li><#AiMesh_OfflineTips3#></li>";
	msg_text += "<li><#AiMesh_OfflineTips4#></li>";
	msg_text += "<li><#AiMesh_OfflineTips5#></li>";
	$msg_item.html(msg_text);
	$amesh_hint_content.append($msg_item);

	var $amesh_action_bg = $('<div>');
	$amesh_action_bg.addClass("amesh_action_bg");
	$offlineHtml.append($amesh_action_bg);

	var $amesh_ok = $('<input/>');
	$amesh_ok.addClass("button_gen");
	$amesh_ok.attr({"type" : "button", "value" : "<#CTL_ok#>"});
	$amesh_action_bg.append($amesh_ok);
	$amesh_ok.click(
		function() {
			if($('.amesh_popup_bg').length == 1) {
				$('.amesh_popup_bg').remove();
			}
			if(_checkFlag) {
				detect_update();
			}
		}
	);

	$("#amesh_offline_msg").fadeIn(300);
	cal_panel_block("amesh_offline_msg", 0.25);
	adjust_panel_block_top("amesh_offline_msg", 200);
}

function show_amas_fw_result() {
	$.ajax({
		url: '/ajax_onboarding.asp',
		dataType: 'script',
		error: function(xhr) {
			amas_fw_detect();
		},
		success: function() {
			document.getElementById('update_states').style.display = "none";
			document.getElementById('update_states').innerHTML = "";
			document.getElementById('update_scan').style.display = "none";
			for (var idx in get_cfg_clientlist) {
				if(get_cfg_clientlist.hasOwnProperty(idx)) {
					var frs_model_name = get_cfg_clientlist[idx].frs_model_name;
					var mac = get_cfg_clientlist[idx].mac;
					var newfwver = get_cfg_clientlist[idx].newfwver;
					var mac_id = mac.replace(/:/g, "");
					var ck_fw_result = "<#is_latest#>";
					var online = get_cfg_clientlist[idx].online;
					$("#amas_" + mac_id + "").children().find(".checkFWResult").html(ck_fw_result);
					if(newfwver != "") {
						ck_fw_result = newfwver;
						$("#amas_" + mac_id + "").children().find(".checkFWResult").addClass("aimesh_fw_release_note");
						$("#amas_" + mac_id + "").children().find(".checkFWResult").html(ck_fw_result);
						$("#amas_update").css("display", "");
						$("#amas_" + mac_id + "").children().find(".checkFWResult").click({"model_name": frs_model_name, "newfwver": newfwver}, show_fw_release_note);
					}
					if(online == "1")
						$("#amas_" + mac_id + "").children("#checkNewFW").css("display", "");
				}
			}
		}
	});
}

function show_current_release_note(event) {
	if($(".confirm_block").length > 0)
		$(".confirm_block").remove();

	document.amas_release_note.model.value = event.data.model_name;
	document.amas_release_note.version.value = event.data.fwver;
	document.amas_release_note.submit();
	confirm_asus({
		title: "Release Note",
		//contentA: "<#exist_new#><br>",
		contentA: event.data.model_name+" : "+event.data.fwver,
		//contentC: "<br><#ADSL_FW_note#> <#Main_alert_proceeding_desc5#>",
		contentC: "",
		left_button: "",
		left_button_callback: {},
		left_button_args: {},
		right_button: "<#CTL_close#>",
		right_button_callback: function(){confirm_cancel();},
		right_button_args: {},
		iframe: "get_release_note_amas.asp",
		margin: "100px 0px 0px 25px",
		note_display_flag: note_display
	});

	setTimeout(function(){check_current_release_note_status();}, 2000);
}
function check_current_release_note_status() {
	if($(".confirm_block").length > 0) {
		$.ajax({
			url: '/ajax_onboarding.asp',
			dataType: 'script',
			success: function() {
				switch(cfg_note) {
					case "0" :
						setTimeout(function(){check_current_release_note_status();}, 1000);
						break;
					case "1" :
						show_current_release_note_result(true);
						break;
					case "2" :
					case "3" :
						show_current_release_note_result(false);
						break;
				}
			}
		});
	}
}
function show_current_release_note_result(_status) {
	
	if(_status) {
		$(".confirm_block").children().find("#status_iframe").attr("src", "get_release_note_amas.asp?flag=1");//reload and flag_show
		$(".confirm_block").children().find("#status_iframe").load();
	}
	else
		$(".confirm_block").children().find("#status_iframe").contents().find("#amas_release_note_hint").val("<#FW_rlnote_failed#>");
}

function show_fw_release_note(event) {
	if($(".confirm_block").length > 0)
		$(".confirm_block").remove();

	document.amas_release_note.model.value = event.data.model_name;
	document.amas_release_note.version.value = event.data.newfwver;
	document.amas_release_note.submit();
	confirm_asus({
		title: "Release Note",
		contentA: "<#exist_new#><br>",
		//contentC: "<br><#ADSL_FW_note#> <#Main_alert_proceeding_desc5#>",
		contentC: "",
		left_button: "",
		left_button_callback: {},
		left_button_args: {},
		right_button: "<#CTL_close#>",
		right_button_callback: function(){confirm_cancel();},
		right_button_args: {},
		iframe: "get_release_note_amas.asp",
		margin: "100px 0px 0px 25px",
		note_display_flag: note_display
	});

	setTimeout(function(){check_fw_release_note_status();}, 2000);
}
function check_fw_release_note_status() {
	if($(".confirm_block").length > 0) {
		$.ajax({
			url: '/ajax_onboarding.asp',
			dataType: 'script',
			success: function() {
				switch(cfg_note) {
					case "0" :
						setTimeout(function(){check_fw_release_note_status();}, 1000);
						break;
					case "1" :
						show_fw_release_note_result(true);
						break;
					case "2" :
					case "3" :
						show_fw_release_note_result(false);
						break;
				}
			}
		});
	}
}
function show_fw_release_note_result(_status) {
	
	if(_status) {
		$(".confirm_block").children().find("#status_iframe").attr("src", "get_release_note_amas.asp?flag=1");//reload and flag_show
		$(".confirm_block").children().find("#status_iframe").load();
	}
	else
		$(".confirm_block").children().find("#status_iframe").contents().find("#amas_release_note_hint").val("<#FW_rlnote_failed#>");
}


function show_revertfw_release_note(event) {
	var notice="";
	//alert(event.data.model_name+"/"+event.data.newfwver);
	if($(".confirm_block").length > 0)
		$(".confirm_block").remove();

	document.revertfw_note.model.value = frsmodel;
	document.revertfw_note.version.value = RevertFWver;
	document.revertfw_note.submit();

	notice = "<#FW_note#><br><br>If you want to revert both your main router and node(s) firmware to the previous version, please revert node(s) first before the main router.";		//Untranslated
	if(document.firmware_form.webs_update_enable.value == 1){
		notice += "<br><br>If you would like to revert to previous firmware version, we suggest you temporarily disable auto firmware update to make sure you grant every upgrade.";		//Untranslated
	}
	confirm_asus({
		title: support_site_modelid,
		contentA: "<#FW_item2#> : "+RevertFWver+"<br>",
		contentC: notice,
		left_button: "<#CTL_close#>",
		left_button_callback: function(){confirm_cancel();},
		left_button_args: {},
		right_button: "Revert",
		right_button_callback: function(){revert_fw_confirm();},
		right_button_args: {},
		iframe: "get_release_note_revertfw.asp",
		margin: "100px 0px 0px 25px",
		note_display_flag: note_display
	});
	$(".confirm_button_gen_long_right").css("display", "none");

	setTimeout(function(){show_revertfw_release_note_result(true);}, 2000);
}
function show_revertfw_release_note_result(_status) {
	
	if(_status) {
		$(".confirm_block").children().find("#status_iframe").attr("src", "get_release_note_revertfw.asp?flag=1");//reload and flag_show
		$(".confirm_block").children().find("#status_iframe").load();
	}
	else
		$(".confirm_block").children().find("#status_iframe").contents().find("#amas_release_note_hint").val("Previous version is currently unavailable.");/* untranslated */
}
function revert_fw_confirm(){
	document.revert_fw.submit();
}
function check_reverfw_status(link) {
	urlExists(link);
}
function urlExists(url, callback){
	$.ajax({
		type: 'HEAD',
		url: url,
		cache: false,
		success: function(){
			console.log("Yes");
		},
		error: function() {
			console.log("No");
		}
	});
}
function open_AiMesh_node_revertfw(_ip) {
	var url = "http://" + _ip + "/AiMesh_Node_RevertFirmware.asp";
	var window_width = 720;
	var window_height = 720;
	var window_top = screen.availHeight / 2 - window_height / 2;
	var window_left = screen.availWidth / 2 - window_width / 2;
	window.open(url, '_new' ,'width=' + window_width + ',height=' + window_height + ', top=' + window_top + ',left=' + window_left + ',menubar=no,scrollbars=yes,toolbar=no,resizable=no,status=no,location=no,rel=noreferrer');
}
function gen_AiMesh_revertfw_status(_node_ip, _online) {
	var html = "";
	if(_online == "1") {
		html += "<span class='aimesh_fw_update_offline' style='margin-left:0px;' onclick='open_AiMesh_node_revertfw(\"" + _node_ip + "\");'>Revert</span>";
	}
	return html;
}


function open_AiMesh_node_fw_upgrade(event) {
	var url = httpApi.aimesh_get_win_open_url(event.data, "AiMesh_Node_FirmwareUpgrade.asp");
	var window_width = 550;
	var window_height = 550;
	var window_top = screen.availHeight / 2 - window_height / 2;
	var window_left = screen.availWidth / 2 - window_width / 2;
	window.open(url, '_new' ,'width=' + window_width + ',height=' + window_height + ', top=' + window_top + ',left=' + window_left + ',menubar=no,scrollbars=yes,toolbar=no,resizable=no,status=no,location=no');
}
function open_AiMesh_router_fw_upgrade() {
	document.form.file.click();
}
function update_AiMesh_fw() {
	$.ajax({
		url: '/ajax_onboarding.asp',
		dataType: 'script',
		success: function(){
			amesh_offline_flag = false;
			for (var idx in get_cfg_clientlist) {
				if(get_cfg_clientlist.hasOwnProperty(idx)) {
					var model_name = get_cfg_clientlist[idx].model_name;
					var mac = get_cfg_clientlist[idx].mac;
					var fwver = get_cfg_clientlist[idx].fwver;
					var ip = get_cfg_clientlist[idx].ip;
					var online = get_cfg_clientlist[idx].online;
					var mac_id = mac.replace(/:/g, "");
					var capability_value = (get_cfg_clientlist[idx].capability["4"]=="")?0:get_cfg_clientlist[idx].capability["4"];
					var current_fwver = $("#amas_" + mac_id + "").find("#current_version .checkFWCurrent").html();
					if(fwver != current_fwver){

						if(revertfw_support){
							if(idx==0){
								if(RevertFWver != "" && !isSame_org && !isUnderREQ){
									$("#amas_" + mac_id + "").children("#current_version").html("<#ADSL_FW_item1#> : <span class='checkFWCurrent'>" + fwver + "</span><span class='aimesh_fw_revert'>Revert</span>");
								}
							}
							else{
								$("#amas_" + mac_id + "").children("#current_version").html("<#ADSL_FW_item1#> : <span class='checkFWCurrent'>" + fwver + "</span><span class='aimesh_fw_revert_node'></span>");
							}
						}
						else{
							$("#amas_" + mac_id + "").children("#current_version").html("<#ADSL_FW_item1#> : <span class='checkFWCurrent'>" + fwver + "</span>");
						}
					}

					if(afwupg_support && online == 1 && webs_update_enable_orig == 1){
						$("#amas_" + mac_id + "").children().find(".checkFWCurrent").addClass("aimesh_fw_release_note");
						$("#amas_" + mac_id + "").children().find(".checkFWCurrent").click({"model_name": model_name, "fwver": fwver}, show_current_release_note);
					}
					var support_manual_fw = check_AiMesh_fw_version(fwver);
					if(support_manual_fw){
						var last_online = $("#amas_" + mac_id + "").attr("current_online");
						if(online != last_online){
							$("#amas_" + mac_id + "").attr("current_online", online);
							$("#amas_" + mac_id + "").children("#manual_firmware_update").empty();
							$("#amas_" + mac_id + "").children("#manual_firmware_update").append(gen_AiMesh_fw_status(support_manual_fw, get_cfg_clientlist[idx]));
							if(online == "1")
								$("#amas_" + mac_id + "").children().find(".aimesh_fw_update_offline").click(get_cfg_clientlist[idx], open_AiMesh_node_fw_upgrade);
						}

						if(online == "0")
							amesh_offline_flag = true;
					}
					else{
						$("#amas_" + mac_id + "").children("#manual_firmware_update").empty();
						$("#amas_" + mac_id + "").children("#manual_firmware_update").append(gen_AiMesh_fw_status(support_manual_fw, get_cfg_clientlist[idx]));
					}
					if(capability_value & 4096){     //no_fw_manual_support
						$("#amas_" + mac_id + "").children("#manual_firmware_update").empty();
					}

					if(revertfw_support){
						if(idx==0){
							if(RevertFWver != "" && !isSame_org && !isUnderREQ){
								$("#amas_" + mac_id + "").children().find(".aimesh_fw_revert").click(show_revertfw_release_note);
							}
						}
						else{
							if(capability_value & 128){	//revertfw_support
								if(!revertfw_support){
									//do nothing
								}
								else{
									$("#amas_" + mac_id + "").children().find(".aimesh_fw_revert_node").html(gen_AiMesh_revertfw_status( ip, online ));
								}
							}
						}
					}
				}
			}
		}
	});
}
function gen_AiMesh_fw_status(_manual_status, _node_info) {
	var html = "";
	if(_manual_status) {
		html += "<#FW_manual_update#> : ";
		if(_node_info.online == "0") {
			html += "<span class='aimesh_fw_update_offline' style='margin-left:0px;' onclick='show_offline_msg(false);'><#Clientlist_OffLine#></span>";
		}
		else {
			html += "<span class='aimesh_fw_update_offline' style='margin-left:0px;' ><#CTL_upload#></span>";
		}
	}
	else {
		html += "<span class='aimesh_fw_update_offline' style='margin-left:0px;text-decoration:none;cursor:none;'><#FW_note_AiMesh_auto#></span>";
	}
	return html;
}
function check_AiMesh_fw_version(_fw) {
	var manual_status = true;
	if(support_site_modelid == "GT-AC2900_SH"){
		manual_status = false;
	}
	return manual_status;
}

function upgrade_modem_fw(){
	if(document.modem_form.file.value.length == 0){
		alert("<#JS_Shareblanktest#>");
		document.modem_form.focus();
		return;
	}
	showLoading(300);
	document.modem_form.submit();
	setTimeout(get_mobile_fw_upgrade_status, 15000);
	setTimeout("detect_httpd();", 272000);
}


function get_mobile_fw_upgrade_status(){
	if(gobi_support){
		var upgrade_status = httpApi.nvramGet(["mobile_upgrade_md5", "mobile_upgrade_name", "mobile_upgrade_process", "mobile_upgrade_now", "mobile_upgrade_status"]);

		if(upgrade_status.mobile_upgrade_md5 != "1" && upgrade_status.mobile_upgrade_name != "1" && upgrade_status.mobile_upgrade_process != "100" && upgrade_status.mobile_upgrade_now != "1")
			setTimeout(get_mobile_fw_upgrade_status, 1000);
		else{
			if(upgrade_status.mobile_upgrade_md5 == "1" || upgrade_status.mobile_upgrade_name == "1")
				alert("<#Mobile_lte_upgrade_wrong_fw#>");
			else if(upgrade_status.mobile_upgrade_now == "1")
				alert("<#Mobile_lte_upgrade_fail#>");
			else if(upgrade_status.mobile_upgrade_status == "3")
				alert("<#Contact_customer_service#>");
		}
	}
	else
		return;
}
</script>
</head>
<body onload="initial();" class="bg">

<div id="TopBanner"></div>

<div id="LoadingBar" class="popup_bar_bg">
<table cellpadding="5" cellspacing="0" id="loadingBarBlock" class="loadingBarBlock" align="center">
	<tr>
		<td height="80">
		<div id="loading_block1" class="Bar_container">
			<span id="proceeding_img_text"></span>
			<div id="proceeding_img"></div>
		</div>
		<div id="loading_block2" style="margin:5px auto; width:85%;"><#FIRM_ok_desc#><br><#Main_alert_proceeding_desc5#></div>
		<div id="loading_block3" style="margin:5px auto;width:85%; font-size:12pt;"></div>
		</td>
	</tr>
</table>
<!--[if lte IE 6.5]><iframe class="hackiframe"></iframe><![endif]-->
</div>
<div id="Loading" class="popup_bg"></div><!--for uniform show, useless but have exist-->

<div id="hiddenMask" class="popup_bg">
	<table cellpadding="5" cellspacing="0" id="dr_sweet_advise" class="dr_sweet_advise" align="center" style="height:100px;">
		<tr>
		<td>
			<div class="drword" id="drword" style="">&nbsp;&nbsp;&nbsp;&nbsp;<#Main_alert_proceeding_desc4#> <#Main_alert_proceeding_desc1#>...</div>
		</td>
		</tr>
	</table>
<!--[if lte IE 6.5]><iframe class="hackiframe"></iframe><![endif]-->
</div>

<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>

<form method="post" action="upgrade.cgi" name="form" target="hidden_frame" enctype="multipart/form-data">
<input type="hidden" name="current_page" value="Advanced_FirmwareUpgrade_Content.asp">
<input type="hidden" name="next_page" value="">
<input type="hidden" name="action_mode" value="">
<input type="hidden" name="action_script" value="">
<input type="hidden" name="action_wait" value="">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">

<table class="content" align="center" cellpadding="0" cellspacing="0">
	<tr>
		<td width="17">&nbsp;</td>

		<td valign="top" width="202">
		<div id="mainMenu"></div>
		<div id="subMenu"></div>
		</td>

    <td valign="top">
	<div id="tabMenu" class="submenuBlock"></div>
		<!--===================================Beginning of Main Content===========================================-->
<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
	<tr>
		<td align="left" valign="top" >

		<table width="760px" border="0" cellpadding="5" cellspacing="0" class="FormTitle" id="FormTitle">
		<tbody>
		<tr>
		  <td bgcolor="#4D595D" valign="top">
		  <div>&nbsp;</div>
		  <div class="formfonttitle"><#menu5_6#> - <#menu5_6_3#></div>
		  <div style="margin:10px 0 10px 5px;" class="splitLine"></div>
		  <br>

		<!-- Firmware Version Info (read-only, UBI layout does not support web upgrade) -->
		<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
			<thead>
				<tr>
					<td colspan="2"><#FW_item2#></td>
				</tr>
			</thead>
			<tr id="productid_tr">
				<th><#FW_item1#></th>
				<td><#Web_Title2#></td>
			</tr>
			<tr id="fw_version_tr">
				<th><#FW_item2#></th>
				<td>
					<div id="FWString" style="height:33px;margin-top:5px;"></div>
				</td>
			</tr>
		</table>

		<br>

		<!-- U-Boot Recovery Firmware Upgrade Instructions -->
		<table id="uboot_recovery_section" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="display:none;">
			<thead>
				<tr>
					<td colspan="2">
						<span class="uboot_lang_en">Firmware Upgrade via U-Boot Recovery</span>
						<span class="uboot_lang_cn">通过 U-Boot Recovery 升级固件</span>
					</td>
				</tr>
			</thead>
			<tr>
				<td colspan="2" style="padding:15px;">
					<div style="line-height:2.0;">
						<p class="uboot_lang_en"><strong>This device uses Mediatek Stock UBI layout and does not support firmware upgrade through the web interface. Please use U-Boot recovery mode to upgrade firmware.</strong></p>
						<p class="uboot_lang_cn"><strong>此设备使用 Mediatek Stock UBI 分区布局，不支持通过网页界面升级固件。请通过 U-Boot Recovery 模式升级固件。</strong></p>
						<hr style="border-color:#6b8fa3;">
						<p class="uboot_lang_en"><strong>Steps:</strong></p>
						<p class="uboot_lang_cn"><strong>操作步骤:</strong></p>
						<ol class="uboot_lang_en">
							<li>Download the latest firmware <code>.img</code> file and save it to your computer.</li>
							<li>Power off the router.</li>
							<li>Press and hold the <strong>RESET</strong> button, then power on the router while continuing to hold RESET for about <strong>10 seconds</strong>.</li>
							<li>Release the RESET button when the power LED starts flashing (indicating U-Boot recovery mode).</li>
							<li>Connect your computer to the router's LAN port with an Ethernet cable (DHCP is supported, no need to set static IP).</li>
							<li>Open a web browser and navigate to <strong>http://192.168.1.1</strong> (U-Boot recovery page).</li>
							<li>On the U-Boot recovery page, select <strong>asuswrt</strong> layout from the firmware layout dropdown, then choose the firmware <code>.img</code> file and click <strong>Upload/Update</strong>.</li>
							<li>Wait for the upgrade to complete. The router will reboot automatically.</li>
							<li>After reboot, access the router at <strong>http://192.168.50.1</strong>.</li>
						</ol>
						<ol class="uboot_lang_cn">
							<li>下载最新固件 <code>.img</code> 文件并保存到电脑。</li>
							<li>断开路由器电源。</li>
							<li>按住 <strong>RESET</strong> 按钮不放，接通电源，继续按住 RESET 约 <strong>10 秒</strong>。</li>
							<li>当电源指示灯开始闪烁时（表示已进入 U-Boot Recovery 模式），松开 RESET 按钮。</li>
							<li>用网线将电脑连接到路由器的 LAN 口（支持 DHCP 自动获取 IP，无需手动设置）。</li>
							<li>打开浏览器，访问 <strong>http://192.168.1.1</strong>（U-Boot Recovery 页面）。</li>
							<li>在 U-Boot Recovery 页面中，固件布局选择 <strong>asuswrt</strong>，然后选择固件 <code>.img</code> 文件，点击 <strong>Upload/Update</strong> 上传升级。</li>
							<li>等待升级完成，路由器将自动重启。</li>
							<li>重启后，访问 <strong>http://192.168.50.1</strong> 进入路由器管理页面。</li>
						</ol>
						<hr style="border-color:#6b8fa3;">
						<p class="uboot_lang_en"><strong>Notes:</strong></p>
						<p class="uboot_lang_cn"><strong>注意事项:</strong></p>
						<ul class="uboot_lang_en">
							<li>Do NOT power off the router during the upgrade process.</li>
							<li>If you are unable to access the U-Boot recovery page, try clearing your browser cache or using a different browser.</li>
							<li>Make sure only one LAN connection is active between your computer and the router during recovery.</li>
						</ul>
						<ul class="uboot_lang_cn">
							<li>升级过程中请勿断开路由器电源。</li>
							<li>如果无法访问 U-Boot Recovery 页面，请尝试清除浏览器缓存或更换浏览器。</li>
							<li>恢复模式下请确保电脑与路由器之间只有一条 LAN 线连接。</li>
						</ul>
					</div>
				</td>
			</tr>
		</table>
		<div class="aimesh_manual_fw_update_hint" style="display:none;">
			<#FW_note#> <#FW_note_AiMesh#>
		</div>
		
</form>

<form method="post" action="do_modem_fwupgrade.cgi" name="modem_form" target="hidden_frame" enctype="multipart/form-data">
<input type="hidden" name="current_page" value="Advanced_FirmwareUpgrade_Content.asp">
<input type="hidden" name="next_page" value="">
<input type="hidden" name="action_mode" value="">
<input type="hidden" name="action_script" value="">
<input type="hidden" name="action_wait" value="">
<input type="hidden" name="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">
		<table id="modem_fw_upgrade" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="display: none;">
			<thead>
				<tr>
					<td colspan="2"><#Mobile_modem_fw#></td>
				</tr>
			</thead>
			<tr><th><#Modem_fw_ver#></th><td><div id="usb_modem_act_swver"><% nvram_get("usb_modem_act_swver"); %></div></td></tr>
			<tr>
				<th><#New_modem_fw#></th>
				<td>
					<input type="file" name="file" class="input" style="color:#FFCC00;*color:#000;width: 194px;">
					<input type="button" name="upload" class="button_gen" onclick="upgrade_modem_fw()" value="<#CTL_upload#>" />
				</td>
			</tr>
		</table>
</form>

<form method="post" name="firmware_form" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="productid" value="<% nvram_get("productid"); %>">
<input type="hidden" name="current_page" value="Advanced_FirmwareUpgrade_Content.asp">
<input type="hidden" name="next_page" value="Advanced_FirmwareUpgrade_Content.asp">
<input type="hidden" name="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">
<input type="hidden" name="modified" value="0">
<input type="hidden" name="flag" value="background">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_script" value="saveNvram">
<input type="hidden" name="action_wait" value="1">
<input type="hidden" name="webs_update_enable" value="<% nvram_get("webs_update_enable"); %>">
<input type="hidden" name="webs_update_time" value="<% nvram_get("webs_update_time"); %>">
<input type="hidden" name="webs_update_beta" value="<% nvram_get("webs_update_beta"); %>">
<input type="hidden" name="webs_update_ts" value="<% nvram_get("webs_update_ts"); %>">
</form>		
			  </td>
              </tr>
            </tbody>
            </table>
		  </td>
        </tr>
      </table>
		<!--===================================Ending of Main Content===========================================-->
	</td>

    <td width="10" align="center" valign="top">&nbsp;</td>
	</tr>
</table>

<div id="footer"></div>

<form method="post" name="start_update" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="productid" value="<% nvram_get("productid"); %>">
<input type="hidden" name="current_page" value="Advanced_FirmwareUpgrade_Content.asp">
<input type="hidden" name="next_page" value="Advanced_FirmwareUpgrade_Content.asp">
<input type="hidden" name="flag" value="liveUpdate">
<input type="hidden" name="action_mode" value="">
<input type="hidden" name="action_script" value="">
<input type="hidden" name="action_wait" value="">
<input type="hidden" name="webs_update_trigger" value="">
</form>
<form method="post" name="sig_update" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="productid" value="<% nvram_get("productid"); %>">
<input type="hidden" name="current_page" value="Advanced_FirmwareUpgrade_Content.asp">
<input type="hidden" name="next_page" value="Advanced_FirmwareUpgrade_Content.asp">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_script" value="start_sig_check">
<input type="hidden" name="action_wait" value="">
</form>
<form method="post" name="amas_release_note" action="/applyapp.cgi" target="hidden_frame">
<input type="hidden" name="productid" value="<% nvram_get("productid"); %>">
<input type="hidden" name="current_page" value="Advanced_FirmwareUpgrade_Content.asp">
<input type="hidden" name="next_page" value="Advanced_FirmwareUpgrade_Content.asp">
<input type="hidden" name="action_mode" value="release_note">
<input type="hidden" name="model" value="">
<input type="hidden" name="version" value="">
</form>
<form method="post" name="revert_fw" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="productid" value="<% nvram_get("productid"); %>">
<input type="hidden" name="current_page" value="Advanced_FirmwareUpgrade_Content.asp">
<input type="hidden" name="next_page" value="Advanced_FirmwareUpgrade_Content.asp">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_script" value="stop_upgrade;start_revert_fw">
<input type="hidden" name="action_wait" value="">
<input type="hidden" name="webs_update_trigger" value="">
</form>
<form method="post" name="revertfw_note" action="/applyapp.cgi" target="hidden_frame">
<input type="hidden" name="productid" value="<% nvram_get("productid"); %>">
<input type="hidden" name="current_page" value="Advanced_FirmwareUpgrade_Content.asp">
<input type="hidden" name="next_page" value="Advanced_FirmwareUpgrade_Content.asp">
<input type="hidden" name="action_mode" value="revertfw_release_note">
<input type="hidden" name="model" value="" disabled>
<input type="hidden" name="version" value="" disabled>
</form>
</body>
</html>
