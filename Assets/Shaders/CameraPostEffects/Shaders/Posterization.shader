// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/Posterization" {

	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
		_amount("Tones Amount", int) = 6
		_global("Global Illumination", float) = 0.2
	}

	CGINCLUDE	
	#include "UnityCG.cginc"
	
	struct v2f 
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};
	
	sampler2D _MainTex;
	int _amount;
	float _global;
	
	v2f vert( appdata_img v ) 
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	} 
	
	float4 frag(v2f i) : SV_Target 
	{
		float3 sum = (float3)0;
		sum = tex2D(_MainTex, i.uv).rgb;

		sum *= _amount;
		sum = floor(sum);
		sum /= _amount;
		sum = pow(sum, (float3)_global);

		return float4(sum, 1);
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
