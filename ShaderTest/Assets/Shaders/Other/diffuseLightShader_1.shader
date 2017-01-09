Shader "MyShader/c6/simpleDiffuse"
{
	Properties
	{
		_Diffuse("diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
	}

	SubShader
	{
		Pass
		{
			Tags { "LightMode" = "ForwardBase"}
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
			fixed4 _Diffuse;
			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 color : COLOR;
			};

			v2f vert(in a2v i)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				//计算光照
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
				//漫反射
				fixed3 worldNormal = normalize( mul(i.normal, (float3x3)_World2Object) );
				fixed3 worldLight = normalize( _WorldSpaceLightPos0.xyz );
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));

				o.color = ambient + diffuse;
				return o;
			}

			fixed4 frag(in v2f i):SV_Target
			{
				return fixed4(i.color, 1.0);
			}

			ENDCG

		}
	}

	Fallback "Diffuse"
}