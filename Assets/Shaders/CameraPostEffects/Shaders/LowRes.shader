// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/LowRes" {

	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
		_resX ("ResolutionX", int) = 160
		_resY ("ResolutionY", int) = 120
	}

	CGINCLUDE	
	#include "UnityCG.cginc"
	
	struct v2f 
	{
		float4 pos	: SV_POSITION;
		float2 uv	: TEXCOORD0;
	};
	
	sampler2D _MainTex;
	int _resX;
	int _resY;
	
	v2f vert( appdata_img v ) 
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	} 
	
	float4 frag(v2f i) : SV_Target 
	{
		float2 uv = i.uv;
		uv.x = round(uv.x * _resX) / _resX;
		uv.y = round(uv.y * _resY) / _resY;

		float4 sum = tex2D(_MainTex, uv);

		return fixed4(sum);
	}

	ENDCG 
	
	Subshader 
	{
		Pass 
		{
			ZTest Always 
			Cull Off 
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		} 
	}
	Fallback off	
}
