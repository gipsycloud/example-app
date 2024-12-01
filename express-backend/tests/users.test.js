const request = require("supertest");
const { app } = require("../index");

let mockPool;

jest.mock("../db", () => {
  const originalModule = jest.requireActual("../db");
  return {
    ...originalModule,
    pool: {
      query: jest.fn(),
      ping: jest.fn(),
    },
  };
});

beforeAll(async () => {
  mockPool = require("../db").pool;
  mockPool.query.mockReset();
  console.log("Starting from clean slate db");
});

describe("GET /api/v1/users", () => {
  test("should return a list of users", async () => {
    mockPool.query.mockResolvedValueOnce({
      rows: [
        { id: 1, name: "Harry Yan", email: "harry@yan.com" },
        { id: 2, name: "Jane Doe", email: "jane@doe.com" },
      ],
    });

    const response = await request(app).get("/api/v1/users").expect(200);

    expect(Array.isArray(response.body)).toBe(true);
    expect(response.body).toHaveLength(2);
    expect(response.body[0].name).toBe("Harry Yan");
  });
});

describe("POST /api/v1/users", () => {
  test("should create a new user and return the user details", async () => {
    const newUser = { name: "Harry Yan", email: "harry@yan.com" };

    mockPool.query.mockResolvedValueOnce({
      rows: [{ id: 1 }],
    });

    const response = await request(app)
      .post("/api/v1/users")
      .send(newUser)
      .expect(201);

    expect(response.body.name).toBe(newUser.name);
    expect(response.body.email).toBe(newUser.email);
    expect(response.body.id).toBeDefined();
  });

  test("should return an error if email already exists", async () => {
    const existingUser = { name: "Another Harry", email: "harry@yan.com" };

    mockPool.query.mockRejectedValueOnce({
      constraint: "users_email_key",
    });

    const response = await request(app)
      .post("/api/v1/users")
      .send(existingUser)
      .expect(400);

    expect(response.body.error).toBe(
      "Email already exists. Please use a different email."
    );
  });
});
