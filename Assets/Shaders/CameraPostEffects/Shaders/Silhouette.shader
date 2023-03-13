// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/Silhouette" {
	
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
	}

	CGINCLUDE	
	#include "UnityCG.cginc"
	
	struct v2f 
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};
	
	sampler2D _MainTex;

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
		sum = -18 * tex2D(_MainTex, i.uv);

		float ratio = 0.0001;

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
			sum += tex2D(_MainTex, i.uv + ratio * offsets[j]);
	
			sum /= ratio;
#ifdef INVERT
			return fixed4(sum);
#else
		return fixed4(1 - sum);
#endif
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
			#pragma shader_feature INVERT
			ENDCG
		}  
	}
	Fallback off	
}
