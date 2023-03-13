// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/Lens" {

	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
		_lens("Lens Strength", float) = 0
		_cubic("Screen Adjustment", float) = 0
	}

	CGINCLUDE	
	#include "UnityCG.cginc"
	
	struct v2f 
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};
	
	sampler2D _MainTex;
	float _lens;
	float _cubic;
	
	v2f vert( appdata_img v ) 
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	} 
	
	float4 frag(v2f i) : SV_Target 
	{
		float dist, factor = (float)0;
		dist = pow((i.uv.x - 0.5), 2) + pow((i.uv.y - 0.5), 2);
		factor = 1 + dist * (_lens + _cubic * sqrt(dist));

		float distX, distY = (float)0;
		distX = factor * (i.uv.x - 0.5) + 0.5;
		distY = factor * (i.uv.y - 0.5) + 0.5;

		float4 sum = (float4)sum;
		sum = tex2D(_MainTex, float2(distX, distY));

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
