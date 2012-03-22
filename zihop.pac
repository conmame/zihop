function FindProxyForURL(url, host){
	if(shExpMatch(url, "http://flapi.nicovideo.jp/api/getmarqueev3")){
		return "PROXY localhost:8080";
	}else{
		return "DIRECT";
	}
}
