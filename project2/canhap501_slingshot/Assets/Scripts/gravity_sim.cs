using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class gravity_sim : MonoBehaviour
{
    [SerializeField]
    public float gravitationalConstant = 6.67e-11f; //1000f;
    public float physicsTimeStep = 0.001f;
    public float sun_mass = 1e+06f;
    private float sub_mass;

    GameObject[] celestials;
    planet[] planet_vals;
    private void Awake()
    {
        celestials = GameObject.FindGameObjectsWithTag("Celestial");
        planet_vals = FindObjectsOfType<planet> ();
        int size = celestials.Length;
        Time.fixedDeltaTime = physicsTimeStep;
        Debug.Log("Setting fixedDeltaTime to: " + gravitationalConstant);
        SetInitialVelocity();
    }

    void FixedUpdate()
    {
        for (int i = 0; i < celestials.Length; i++)
        {
            GameObject main_planet = celestials[i];
            Vector2 accel = Vector2.zero;
            

            foreach (GameObject sub_planet in celestials)
            {
                if (!main_planet.Equals(sub_planet))
                {
                    sub_mass = sub_planet.GetComponent<Rigidbody2D>().mass;
                    float r = Vector2.Distance(main_planet.transform.position, sub_planet.transform.position);
                    accel += (Vector2)(sub_planet.transform.position - main_planet.transform.position).normalized * gravitationalConstant * sub_mass / (r * r);
                    
                }

            }
            planet_vals[i].vel += accel * physicsTimeStep;
            //Debug.Log(accel);
        }
        for (int i = 0; i < celestials.Length; i++)
        {
            //if (celestials[i].name != "Sun")
            celestials[i].GetComponent<Rigidbody2D>().MovePosition(celestials[i].GetComponent<Rigidbody2D>().position + planet_vals[i].vel * physicsTimeStep);

        }
    }
    private void SetInitialVelocity()
    {
        Debug.Log("Setting Initial Velocity...\n");
        for (int i = 0; i < celestials.Length; i++)
        {
            GameObject main_planet = celestials[i];
            Debug.Log(main_planet.name);
            foreach (GameObject sub_planet in celestials)
            {
                if (!main_planet.Equals(sub_planet))
                {
                    float sub_planet_mass = sub_planet.GetComponent<Rigidbody2D>().mass;
                    float r = Vector2.Distance(main_planet.transform.position, sub_planet.transform.position);
                    Vector2 vel = (Vector2)main_planet.transform.right * Mathf.Sqrt((gravitationalConstant * sub_planet_mass) / r);
                    Debug.Log(vel.y);
                    planet_vals[i].vel += vel;

                }
            }

        }
        //float r = Vector2.Distance(m_Earth.transform.position, m_Moon.transform.position);
        //m_Moon.GetComponent<Rigidbody2D>().velocity +=
        //    (Vector2)m_Moon.transform.right * Mathf.Sqrt((G * mass_earth) / r);
    }
}
