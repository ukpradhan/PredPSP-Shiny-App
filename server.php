<!DOCTYPE HTML>
<!-- zerotype index.html page -->
<html>
<head>
	<meta charset="UTF-8">
	<title>PredPSP: Server</title>
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
	</style>
	<script>
		function validateform(){   
			var seq=document.form1.sequence.value;  
			var seq2=document.form1.seq2.value;
			var plant_type = document.form1.plant_type.value;
			if (seq=="" && seq2==""){  
				alert("Either paste the protein sequences in FASTA format in the text area OR upload the FASTA sequence file");  
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
		<div style="background-color: #E5E4E2;">	
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
		<div style="background-color: #ECFFDC;border:1px solid #ECFFDC;">
			<p style="text-indent:221px;font:20px 'Times New Roman',serif;font-weight:bold;color:black;">1. Paste the protein sequences in FASTA format</p>
			<form id="form1" name="form1" method="post" action="result.php" enctype="multipart/form-data" onsubmit="return validateform()">
				<?php 
					error_reporting(0);
	  				$exp=$_REQUEST["ex"];
					if($exp=="load")
					{
					$fp = fopen("rcode/gene.fasta", "r");
		
					while(!feof($fp)) {
					$data .= fgets($fp);
						}
    				fclose($fp);
					}
				?>
				<div align = "center">
					<textarea name="sequence" cols="90" rows="10" style="border:solid 1px black;"><?php echo $data;?></textarea>
				</div>
				<center><p style="font:18px 'Times New Roman',serif;font-weight:bold;color:black;"><strong> OR </strong></p></center>
				<center><p style="font:18px 'Times New Roman',serif;font-weight:bold;color:black;"><strong> Upload  Fasta file</strong>&nbsp;<input type="file" name="seq2" id="fileField"/></center> 
				</p>
				<p style="text-indent:221px;font:18px 'Times New Roman',serif;font-weight:bold;color:black;">2. Select Plant Type: &nbsp;&nbsp;&nbsp;<input type="radio" id="c3" name="plant_type" value="c3">&nbsp;<label for="c3" style="font:18px;font-family:arial;font-size:15px;font-weight:bold;color:black;"> C3 </label>	
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="radio" id="c4" name="plant_type" value="c4">&nbsp;<label for="c4" style="font:18px;font-family:arial;font-size:15px;font-weight:bold;color:black;"> C4 </label></p>
				<div align = "center" >
					<button  style="border-radius:8px;background-color:#8D6E63;width:180px;height:40px;border:none;">
					<a class="more" href="server.php?ex=load" style="text-decoration:none;font:18px 'Times New Roman',serif;color:white;font-weight:bold;">Load Example Data</a></button> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<button  style="border-radius:8px;background-color:#8D6E63;width:180px;height:40px;border:none;">
					<a class="more" href="server.php" style="text-decoration:none;font:18px 'Times New Roman',serif;color:white;font-weight:bold;">Clear Textarea</a></button>
					<br/>											
				</div>
				<div align = "center" >
					<br/>
					<label><input style="border-radius:8px;background-color:#0096FF;width:180px;height:40px;border:none;font:18px 'Times New Roman',serif;color:white;font-weight:bold;" type="submit" name="button" class="sub_btn" value="Submit" onclick="checkLength();move();"/></label>	
				</div>
				<br/>
			</form>	
			<div align="center" id="loading_div" style="display:none"><img src="images/loading6.gif" alt="loading" height="90" width="90">
				<p style="font:18px 'Times New Roman',serif; font-size:20px; font-weight:bold;">
				Program execution in progress</p>
			</div>
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