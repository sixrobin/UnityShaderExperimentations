// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/Noise" {

	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
		_noise("Noise Frequency", float) = 0.5
	}

	CGINCLUDE	
	#include "UnityCG.cginc"
	
	struct v2f 
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};
	
	sampler2D _MainTex;
	float _noise;
	
	v2f vert( appdata_img v ) 
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	} 
	
	float4 frag(v2f i) : SV_Target 
	{
	    float4 sum = tex2D(_MainTex, i.uv); 
 
	    float x = i.uv.x * i.uv.y * _Time * 1000 + 10; 
	    x = fmod(x, 20) * fmod(x, 150);  
	    float dx = fmod(x, 0.01f); 

	    float3 parasite = sum.rgb + sum.rgb * saturate(0.001 + dx.xxx * 100); 	 
	 
		float3 color = tex2D(_MainTex, parasite * _noise);

		return fixed4(color * parasite, 0);
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
