// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/Laplacian" {
	
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
		_amplitude("Amplitude", float) = 0.25
	}

	CGINCLUDE	
	#include "UnityCG.cginc"
	
	struct v2f 
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};
	
	sampler2D _MainTex;
	float _amplitude;

	v2f vert( appdata_img v ) 
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	} 
	
	float4 frag(v2f i) : SV_Target 
	{
		float4 sum = (float4)0;
		sum = -9 * tex2D(_MainTex, i.uv);

		float2 offsets[9] = 
		{  
			float2(-1, -1),
			float2(-1, 0),
			float2(-1, 1),
			float2(0, -1),
			float2(0, 0),  
			float2(0, 1),  
			float2(1, -1),
			float2(1, 0),
			float2(1, 1)
		}; 

		for (int j = 0; j < 9; j++)
			sum += tex2D(_MainTex, i.uv + _amplitude/50 * offsets[j]);
#ifdef DBZ		
			sum /= 0.0001;
#endif
#ifdef INVERT
			sum = 1 - sum;
#endif
		return sum; 
	}

	ENDCG 
	
	Subshader {
		Pass {
			ZTest Always 
			Cull Off 
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature DBZ
			#pragma shader_feature INVERT
			ENDCG
		}  
	}
	Fallback off	
}
