Shader "Custom/Equirectangular" {
    Properties {
        _Color ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "gray" {}
        _TransformedNormal ("Transformed Normal", Vector) = (0,0,0,0)
        _Width ("Width", Float) = 4.0 
        _Height ("Height", Float) = 3.0
        _CamDistance ("Cam Distance", Float) = 2.0
        _SphereRadius ("Sphere Radius", Float) = 2.0
    }
 
    SubShader{
        Pass {
            Cull Off
            Tags { "RenderType"="Opaque" }
			
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma fragmentoption ARB_precision_hint_fastest
                #pragma glsl
                #pragma target 3.0
 
                #include "UnityCG.cginc"
 
                struct appdata {
                   float4 vertex : POSITION;
                   float3 normal : NORMAL;
                };
 
                struct v2f
                {
                    float4    pos : SV_POSITION;
                    float3    normal : TEXCOORD0;
                };
 
                v2f vert (appdata v)
                {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.normal = v.normal;
                    return o;
                }
 
                sampler2D _MainTex;
                // center wrt the screen
                float4 _TransformedCenter;
                //rotation of view sphere wrt screen
                float4x4 _CenterRotation;
                float _Width;
                float _Height;
                float _CamDistance;
                float _SphereRadius;
                
              
				#define ONE_OVER_PI .31830988618379067154F
                inline float2 RadialCoords(float3 a_coords)
                {
                    float3 a_coords_n = normalize(a_coords);
                    float4 a_coords4n = float4(a_coords_n, 0.0);
                    float4 mulres = mul(_CenterRotation, a_coords4n);
                    a_coords_n = mulres.xyz;

                    float3 newCenter = _TransformedCenter + a_coords_n * _SphereRadius;
                    float3 newNormal = normalize(newCenter + float3(0.0,0.0,_SphereRadius));

                    //float3 projection_pt = -(_TransformedCenter.z/a_coords_n.z) * a_coords_n + _TransformedCenter;
                    float3 projection_pt = -(newCenter.z/newNormal.z) * newNormal +newCenter;
                    float uv_width = (projection_pt.x + 0.5 * _Width)/_Width;
                    float uv_height=  (projection_pt.y + 0.5 * _Height)/_Height;

                    return float2(uv_width, uv_height);
                    // line: normal * t + center
                    // normal.z * t + center.z = 0
                    // t = -center.z/normal.z
                    //point: -center.z/normal.z * normal + center
                    // float lon = atan2(a_coords_n.z, a_coords_n.x);
                    // float lat = acos(a_coords_n.y);
                    // float2 sphereCoords = float2(lon, lat) * ONE_OVER_PI;
                    // return float2(sphereCoords.x * 0.5 + 0.5, 1 - sphereCoords.y);
                }
 
                float4 frag(v2f IN) : COLOR
                {
                    if (IN.normal.z < 0)
                    {
                        return float4(0.0,0.0,0.0,1.0);
                    }
                    float2 equiUV = RadialCoords(IN.normal);
                    if (equiUV.x < 0.0 || equiUV.x > 1.0 || equiUV.y < 0.0 || equiUV.y > 1.0)
                    {
                        return float4(0.0,0.0,0.0,1.0);
                    }
                    return tex2D(_MainTex, equiUV);
                }
            ENDCG
        }
    }
    FallBack "VertexLit"
}