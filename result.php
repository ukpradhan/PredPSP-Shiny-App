<!DOCTYPE HTML>
<!-- zerotype index.html page -->
<html>
<head>
	<meta charset="UTF-8">
	<title>PredPSP: Result</title>
	<link rel="stylesheet" type="text/css">
	<style>
		.container {
			display: flex;
			align-items: center;
			justify-content: center
		}
		img {
			max-width: 100%;
			max-height:100%;
		}
		.text {
			font-size: 20px;
			padding-left: 20px;
		}
	</style>
	<script>
		function validateform(){   
			var seq=document.form1.sequence.value;  
			var seq2=document.form1.seq2.value;
			var plant_type = document.form1.plant_type.value;
			if (seq=="" && seq2==""){  
				alert("Either paste the Photosynthetic protein sequences in FASTA format in the text area OR upload the FASTA sequence file");  
				return false;  
			}else if(plant_type == ""){  
				alert("Please select Plant Type ");  
				return false;  
			}
			var x = document.getElementById("loading_div");
  			if (x.style.display === "none"){
    	    		x.style.display = "block";	
  			} 
			else {
    				x.style.display = "none";
  			}
			return true;
		}
	</script>
</head>
<body>
	<div id="container" style="margin: auto;width:60%;">
		<div style="background-color:#E5E4E2;">	
			<div class="container">
				<div class="image" style="padding-right: 26px;"><img src="images/logo_psp.png" alt="image not found" height="120" width="250"></div>
				<p style="font:25px 'Times New Roman', serif;font-weight: bold;color:#0047AB;text-align:center;"><i>Pred</i>PSP: A Web Server for Photosynthetic Protein Prediction in Plants</p>
			</div> 	
		</div>
		<div>
			<div style="text-align:center;background-color:#7393B3;margin:auto;height:30px;width:100%;padding-top:2px;">
				<a href="index.html" style="padding: 30px;font:20px 'Times New Roman', serif;font-weight: bold;color:white;text-decoration: none;">Home</a>			
				<a href="server.php" style="padding: 30px;font:20px 'Times New Roman', serif;font-weight: bold;color:white;text-decoration: none;">Run Server</a>
				<a href="dataset.html" style="padding: 30px;font:20px 'Times New Roman', serif;font-weight: bold;color:white;text-decoration: none;">Dataset</a>
				<a href="help.html" style="padding: 30px;font:20px 'Times New Roman', serif;font-weight: bold;color:white;text-decoration: none;">Help</a>
				<a href="contact.html" style="padding: 30px;font:20px 'Times New Roman', serif;font-weight: bold;color:white;text-decoration: none;">Contact Us</a>
			</div>
		</div>
		<div style="background-color: #C1E1C1;border:1px solid #C1E1C1;">
			<center>
				<p style="font:20px 'Times New Roman', serif;font-weight: bold;color:black;">Prediction Result</p><br/>
				<?php 
  					// error_reporting(0);  
					$seq=$_REQUEST["sequence"];
    
					if ($_FILES["seq2"]["error"] > 0)
					{
					$file = fopen("rcode/test.fasta","w");
					fwrite($file,$seq);
					}
					else
					{
					copy($_FILES["seq2"]["tmp_name"], "rcode/test.fasta");  
					}
				$plant_type = $_POST['plant_type'];  
				if($plant_type == 'c3' ){
					$cm="C:/PROGRA~1/R/R-3.6.0/bin/Rscript C:/Apache24/htdocs/predpsp/rcode/psp_c3.R";
				}elseif($plant_type == 'c4'){
					$cm="C:/PROGRA~1/R/R-3.6.0/bin/Rscript C:/Apache24/htdocs/predpsp/rcode/psp_c4.R";
				}else{
					species_selection_error();
				}
				exec($cm, $output);
				$file="psp";
				?>
				<center><iframe src="rcode/<?php echo $file.".html" ;?>" height="350" width="500" frameborder="0"></iframe></center>
			</center>
		</div>
		<div class="row" style="background-color:#E5E4E2;">
			<div class="container">
				<div class="image" style="padding-right: 26px;">
					<a href="https://icar.org.in/" target="_blank">
					<img src="images/icarlogo.png" alt="image not found" width="60" height="80"></a>
				</div>        
				<p style="margin:auto;font:18px 'Times New Roman', serif;color:#0047AB;font-weight:bold;">Developed @ ICAR-IASRI, Pusa, New Delhi - 110012</p>
				<div class="image" style="padding-right: 26px;">
					<a href="https://iasri.icar.gov.in/" target="_blank">
					<img src="images/iasri_logo.png" alt="image not found"  width="80" height="80"></a>
				</div>
			</div>
		</div>
		<div class="row">
			<center>
				<div style="width:400px; height:300px;"><script type="text/javascript" id="clustrmaps" src="//clustrmaps.com/map_v2.js?d=4_i48pTFCI61SmRq8iu8e3HDQFBiIU43v0nxKaSX7Fc&cl=ffffff&w=a"></script>
				</div>
			</center>
		</div>
	</div>
</body>
</html>